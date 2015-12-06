class Explosion < StandardError
end

class Tile
  COLORS = {
    1 => :light_blue,
    2 => :green,
    3 => :light_red,
    4 => :blue,
    5 => :magenta,
    6 => :light_green,
    7 => :grey,
    8 => :light_black
  }

  neighborhood = [-1,0,1].product [-1,0,1]
  OFFSETS = neighborhood.reject { |pos| pos == [0,0] }

  attr_reader :revealed, :flagged
  alias_method :revealed?, :revealed
  alias_method :flagged?, :flagged

  def initialize(pos, board = nil)
    @type = :clear
    @pos = pos
    @board = board
    @revealed = false
    @flagged = false
  end

  def bomb?
    type == :bomb
  end

  def clear?
    type == :clear
  end

  def flag
    self.flagged = !flagged
  end

  def place_bomb
    self.type = :bomb
  end

  def reveal
    return if flagged?
    raise Explosion, "You lose!" if bomb?

    self.revealed = true
    @neighbors ||= get_neighbors

    if neighbor_bomb_count.zero? || neighbor_bomb_count == neighbor_flagged_count
      neighbors.each do |neighbor|
        neighbor.reveal unless neighbor.revealed? || neighbor.flagged?
      end
    end
  end

  def reveal_self
    self.revealed = true
    self.flagged = bomb? #for final bomb count of 0
    @neighbors ||= get_neighbors
  end

  def to_s
    if bombed?
      "\u2055"
    elsif flagged?
      "\u2691".red
    elsif neighboring_bombs?
      color neighbor_bomb_count
    elsif zero_neighboring_bombs?
      " "
    elsif !revealed?
      "O".white
    end
  end

  private
  attr_accessor :type
  attr_reader :board, :pos, :neighbors
  attr_writer :revealed, :flagged

  def bombed?
    bomb? && revealed?
  end

  def board_boundary_filter(positions)
    positions.select do |pos|
      pos.all? { |coord| coord.between? 0, board.size - 1 }
    end
  end

  def color(bomb_count)
    color = COLORS[bomb_count]
    bomb_count.to_s.colorize(color)
  end

  def get_neighbors
    valid_positions = board_boundary_filter neighbor_positions
    valid_positions.map { |pos| board[pos] }
  end

  def neighbor_bomb_count
    neighbors.count { |neighbor| neighbor.bomb? }
  end

  def neighbor_flagged_count
    neighbors.count { |neighbor| neighbor.flagged? }
  end

  def neighbor_positions
    OFFSETS.map do |offset_row, offset_col|
      neighbor_row = offset_row + pos[0]
      neighbor_col = offset_col + pos[1]
      [neighbor_row, neighbor_col]
    end
  end

  def neighboring_bombs?
    revealed? && neighbor_bomb_count > 0
  end

  def zero_neighboring_bombs?
    revealed? && neighbor_bomb_count.zero?
  end
end
