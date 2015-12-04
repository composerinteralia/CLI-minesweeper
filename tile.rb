require 'byebug'

class Tile
  OFFSETS = [-1,0,1].product([-1,0,1]).reject { |pos| pos == [0,0] }

  attr_reader :type, :board, :revealed, :flagged, :pos, :neighbors

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
    @neighbors ||= get_neighbors

    if neighbor_bomb_count.zero?
      neighbors.each { |neighbor| neighbor.reveal unless neighbor.revealed? }
    end
  end

  def get_neighbors
    possible_positions = get_neighbor_positions
    valid_pos = get_valid_positions(possible_positions)

    valid_pos.map { |pos| board[pos] }
  end

  def neighbor_bomb_count
    neighbors.count { |neighbor| neighbor.type == :bomb}
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

  private
  def get_neighbor_positions
    OFFSETS.map do |offset_row, offset_col|
      neighbor_row = offset_row + pos[0]
      neighbor_col = offset_col + pos[1]
      [neighbor_row, neighbor_col]
    end
  end

  def get_valid_positions(possible_positions)
    possible_positions.select do |neighbor|
      neighbor.all? { |idx| idx.between?(0, board.size - 1) }
    end
  end
end
