#!/usr/bin/env ruby

require 'colorize'
require_relative 'tile'
require_relative 'board'
require_relative 'display'

class Game
  def self.with_custom_board(size, bomb_total)
    bomb_total ||= 0
    board = Board.new(size, bomb_total)
    self.new(board)
  end

  def initialize(board = nil)
    board ||= Board.new
    @board = board
    @display = Display.new(board)
  end

  def run
    first_turn = true

    until over?
      position, move_type = get_move

      begin
        start_time = Time.now if first_turn
        board.move(position, move_type)
        first_turn = false

      rescue Explosion => losing_pos
        if first_turn
          @board = Board.new(board.size, board.bomb_total)
          @display = Display.new(board, display.cursor_pos)
          retry
        end

        return lose
      end
    end

    win(start_time)
  end

  private
  attr_reader :board, :display

  def get_move
    move = nil
    until move
      display.render
      move = display.get_input
    end
    move
  end

  def lose
    board.reveal_all
    display.render
    puts "You lose!".red
  end

  def over?
    board.won?
  end

  def win(start_time)
    board.reveal_unflagged_bombs
    display.render

    play_time = (Time.now - start_time).round
    puts "Congratulations! You won in #{play_time} seconds!".green
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    game = Game.new
  else
    board_size, bomb_total = ARGV.shift(2).map(&:to_i)
    game = Game.with_custom_board(board_size, bomb_total)
  end

  game.run
end
