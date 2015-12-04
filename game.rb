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
      move = get_turn
      begin
        board.make_move(move)
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
    print "Enter row: "
    row = gets.chomp.to_i
    print "Enter col: "
    col = gets.chomp.to_i

    move = [row, col]

    until move.all? { |coord| coord.between?(0, board.size - 1) }
      puts "Invalid move, try again."
      move = get_turn
    end

    move
  end

  def over?
    board.won?
  end
end

Game.new.run
