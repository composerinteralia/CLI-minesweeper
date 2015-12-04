require 'byebug'

class Tile
  OFFSETS = [-1,0,1].product([-1,0,1]).reject { |pos| pos == [0,0] }

  attr_reader :type, :board, :revealed, :flagged, :pos

  def initialize(pos, board = nil)
    @type = :clear
    @pos = pos
    @board = board
    @revealed = false
    @flagged = false
  end

  def place_bomb
    @type = :bomb
  end

  def clear?
    type == :clear
  end

  def reveal
    @revealed = true
    @neighbors ||= neighbors
  end

  def neighbors
    neighbors_pos = OFFSETS.map do |offset_row, offset_col|
      neighbor_row = offset_row + pos[0]
      neighbor_col = offset_col + pos[1]
      [neighbor_row, neighbor_col]
    end

    valid_pos = neighbors_pos.select do |neighbor|
      neighbor.all? { |idx| idx.between?(0, board.size - 1) }
    end

    valid_pos.map { |pos| board[pos] }
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

  def inspect
    type
  end

  def to_s
    if bombed?
      "*"
    elsif revealed?
      "_"
    elsif flagged?
      "F"
    else
      "O"
    end
  end
end
