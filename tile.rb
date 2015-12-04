class Tile
  attr_reader :type, :board

  def initialize(type, board)
    @type = type
    @board = board
    @revealed = false
  end

  def reveal
    @revealed = true
    type
  end

end
