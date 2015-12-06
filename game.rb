#!/usr/bin/env ruby

require 'colorize'
require './tile'
require './board'

class Game
  MOVE_TYPES = [:r, :f]

  def self.from_custom_board(size, bomb_total)
    bomb_total ||= 0
    board = Board.new(size, bomb_total)
    self.new(board)
  end

  def initialize(board = nil)
    board ||= Board.new
    @board = board
  end

  def run
    first_turn = true

    until over?
      board.render

      position, move_type = get_move
      begin
        start_time = Time.now if first_turn
        board.move(position, move_type)
        first_turn = false

      rescue Explosion => alert
        if first_turn
          @board = Board.new(board.size, board.bomb_total)
          retry
        end

        board.losing_render
        return puts alert
      end
    end

    board.winning_render

    play_time = (Time.now - start_time).round
    puts "Congratulations! You won in #{play_time} seconds!"
  end

  private
  attr_reader :board

  def bad_parse?(move)
    move.flatten.size != 3
  end

  def in_bounds?(position)
    position.all? { |coord| coord.between? 0, board.size - 1 }
  end

  def get_move
    puts "Type 'r' (reveal) or 'f' (flag) followed by"\
         "a row and column (e.g. 'r 0 0')."
    print ">"

    move = parse input
    until valid_move? move
      print ">"
      move = parse input
    end

    move
  end

  def input
    STDIN.gets.chomp
  end

  def over?
    board.won?
  end

  def parse(raw_input)
    chars = raw_input.each_char.reject { |char| [" ", ",", "-"].include? char }

    move_type = chars.shift.downcase.to_sym
    position = chars.map { |coord| coord.to_i 36 }
    [position, move_type]
  end

  def valid_move?(move)
    if bad_parse? move
      print "Invalid input. "
    elsif !valid_flag? move[1]
      print "Incorrect move type (type 'r' or 'f'). "
    elsif !in_bounds? position = move[0]
      position = position.map { |coord| coord.to_s 36 }
      print "#{position.join(", ")} is not a valid position. "
    else
      return true
    end

    puts "Try again."
    false
  end

  def valid_flag?(flag)
    MOVE_TYPES.include? flag
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    game = Game.new
  else
    board_size, bomb_total = ARGV.shift(2).map(&:to_i)
    game = Game.from_custom_board(board_size, bomb_total)
  end

  game.run
end
