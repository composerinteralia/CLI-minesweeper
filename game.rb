#!/usr/bin/env ruby

require 'colorize'
require './tile'
require './board'

class Game
  def self.from_custom_board(size, num_bombs)
    num_bombs ||= 0
    board = Board.new(size, num_bombs)
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
        board.make_move(position, move_type)
        first_turn = false

      rescue Explosion => alert
        if first_turn
          @board = Board.new(board.size, board.num_bombs)
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

  def over?
    board.won?
  end

  def get_move
    puts "Type 'r' (reveal) or 'f' (flag) followed by a row and column. (e.g. 'r 0 0')."
    print ">"

    move = parse(get_input)
    until validate move
      print ">"
      move = parse(get_input)
    end

    move
  end

  def get_input
    STDIN.gets.chomp
  end

  def parse(input)
    chars = input.split("").reject { |char| [" ", ",", "-"].include? char }

    move_type = chars.shift.downcase
    position = chars.map { |coord| coord.to_i(36) }
    [position, move_type]
  end

  def validate(move)
    if move.flatten.size != 3
      puts "Invalid input. Try again."
    elsif !valid_flag? move[1]
      puts "Incorrect move type (type 'r' or 'f'). Try again."
    elsif !in_bounds? position = move[0]
      position = position.map { |coord| coord.to_s(36) }
      puts "#{position.join(", ")} is not a valid position. Try again."
    else
      return true
    end

    false
  end

  def in_bounds?(position)
    position.all? { |coord| coord.between?(0, board.size - 1) }
  end

  def valid_flag?(flag)
    flag == "f" || flag == "r"
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    game = Game.new
  else
    board_size, num_bombs = ARGV.shift(2).map(&:to_i)
    game = Game.from_custom_board(board_size, num_bombs)
  end

  game.run
end
