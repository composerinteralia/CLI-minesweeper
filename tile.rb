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
  OFFSETS = neighborhood.reject { |pos| pos == [0, 0] }

  attr_reader :revealed, :flagged, :bomb
  alias_method :revealed?, :revealed
  alias_method :flagged?, :flagged
  alias_method :bomb?, :bomb

  def initialize(board, pos)
    @pos = pos
    @board = board
    @revealed, @flagged, @bomb, @loser = false, false, false, false
  end

  def clear?
    !bomb
  end

  def toggle_flag
    self.flagged = !flagged unless revealed?
  end

  def plant_bomb
    self.bomb = true
  end

  def reveal
    return self if flagged?
    raise Explosion if bomb?

    self.revealed = true
    @neighbors = explore_neighborhood
    @neighboring_bomb_count = count_neighboring_bombs

    if zero_neighboring_bombs? || all_neighboring_bombs_flagged?
      neighbors.each { |tile| tile.reveal unless tile.revealed? }
    end
  end

  def reveal_self
    self.revealed = true
    self.flagged = bomb? #for final bomb count of 0
    @neighbors ||= explore_neighborhood
    @neighboring_bomb_count ||= count_neighboring_bombs
  end

  def to_s
    if exploded?
      "\u2055"
    elsif flagged?
      "\u2691".red
    elsif neighboring_bombs?
      color neighboring_bomb_count
    elsif zero_neighboring_bombs?
      " "
    elsif !revealed?
      "\u25A0".light_black
    end
  end

  private
  attr_reader :board, :pos, :neighbors, :neighboring_bomb_count
  attr_writer :revealed, :flagged, :bomb

  def all_neighboring_bombs_flagged?
    neighboring_bomb_count == neighbor_flagged_count
  end

  def board_boundary_filter(positions)
    positions.select { |position| board.in_bounds?(position) }
  end

  def color(bomb_count)
    color = COLORS[bomb_count]
    bomb_count.to_s.colorize(color)
  end

  def exploded?
    bomb? && revealed?
  end

  def explore_neighborhood
    valid_positions = board_boundary_filter neighbor_positions
    valid_positions.map { |pos| board[pos] }
  end

  def count_neighboring_bombs
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
    revealed? && neighboring_bomb_count > 0
  end

  def zero_neighboring_bombs?
    revealed? && neighboring_bomb_count.zero?
  end
end
