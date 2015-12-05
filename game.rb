#!/usr/bin/env ruby

require 'colorize'
require './tile'
require './board'

class Game
  attr_reader :board

  def initialize
    @board = Board.new
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
          @board = Board.new #bug
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
    move_type = gets.chomp.downcase[0]

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
    gets.chomp.to_i(36)
  end

  def in_bound?(position)
    position.all? { |coord| coord.between?(0, board.size - 1) }
  end

  def over?
    board.won?
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new.run
end
