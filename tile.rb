class Tile
  attr_reader :type, :board, :revealed

  def initialize(type, board = nil)
    @type = type
    @board = board
    @revealed = false
  end

  def reveal
    @revealed = true
    type
  end

  def bombed?
    type == :bomb && revealed
  end

end
