class Tile
  attr_reader :type, :board, :revealed, :flagged

  def initialize(type, board = nil)
    @type = type
    @board = board
    @revealed = false
    @flagged = false
  end

  def reveal
    @revealed = true
    type
  end

  def flag
    @flagged = !flagged
  end

  def flagged?
    flagged
  end

  def bombed?
    type == :bomb && revealed
  end

  def revealed?
    revealed
  end

end
