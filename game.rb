#!/usr/bin/env ruby

require 'colorize'
require './tile'
require './board'

class BombOverflow < StandardError
end


class Game
  def self.from_custom_board(size, num_bombs)
    num_bombs ||= 0

    max_num_bombs = size ** 2 - 2
    if num_bombs > max_num_bombs
      raise BombOverflow,
        "Too many bombs (#{num_bombs}) for board size (#{size}). "\
        "Allow at least two clear positions (#{max_num_bombs} bombs or fewer)."
    end

    board = Board.new(size, num_bombs)
    self.new(board)
  end

  attr_reader :board

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

    play_time = (Time.now - start_time).round
    board.winning_render
    puts "Congratulations! You won in #{play_time} seconds!"
  end

  def get_move
    print "Reveal (r) or Flag (f)?"
    move_type = STDIN.gets.chomp.downcase[0]

    print "Enter row: "
    row = get_i
    print "Enter col: "
    col = get_i

    position = [row, col]
    move = [position, move_type]
    until in_bound? position
      puts "Not on the grid, try again."
      move = get_move
      position = move[0]
    end

    move
  end

  def get_i
    STDIN.gets.chomp.to_i(36)
  end

  def in_bound?(position)
    position.all? { |coord| coord.between?(0, board.size - 1) }
  end

  def over?
    board.won?
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
