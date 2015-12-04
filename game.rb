require './tile'
require './board'

class Game
  def initialize(board = nil)
    @board ||= Board.new
  end
end

game = Game.new
