#!/usr/bin/env ruby

require './tile'
require './board'

class Game
  attr_reader :board

  def initialize(board = nil)
    @board ||= Board.new
  end

  def run
    until over?
      board.render
      position, move_type = get_turn
      begin
        board.make_move(position, move_type)
      rescue Explosion
        board.reveal_all
        board.render
        puts "You lose!"
        return
      end
    end

    puts "Congratulations! You won!"
  end

  def get_turn
    print "Reveal (r) or Flag (f)?"
    answer = gets.chomp.downcase[0]

    print "Enter row: "
    row = gets.chomp.to_i
    print "Enter col: "
    col = gets.chomp.to_i

    move = [[row, col], answer]

    until move[0].all? { |coord| coord.between?(0, board.size - 1) }
      puts "Invalid move, try again."
      move = get_turn
    end

    move
  end

  def over?
    board.won?
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new.run
end
