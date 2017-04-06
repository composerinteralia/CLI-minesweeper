class BombOverflow < StandardError
end

class Board
  attr_reader :size, :bomb_total, :grid

  def initialize(size = 9, bomb_total = 10)
    @size, @bomb_total = size, bomb_total
    validate_bomb_total
    generate_grid
  end

  def [](pos)
    row, col = pos
    grid[row][col]
  end

  def in_bounds?(position)
    position.all? { |coord| coord.between? 0, size - 1 }
  end

  def move(position, move_type)
    tile = self[position]

    tile.toggle_flag if move_type == :flag
    tile.reveal if move_type == :reveal
  end

  def remaining_bombs_s
    remaining = bomb_total - flagged_bombs
    remaining < 0 ? remaining.to_s.red : remaining.to_s.green
  end

  def reveal_all
    tiles.each(&:reveal_self)
  end

  def reveal_unflagged_bombs
    tiles.each { |tile| tile.reveal_self unless tile.flagged? }
  end

  def won?
    tiles.all? { |tile| tile.revealed? || tile.bomb? }
  end

  private
  def flagged_bombs
    tiles.count(&:flagged?)
  end

  def generate_grid
    @grid = Array.new(size) do |row|
      Array.new(size) { |col| Tile.new self, [row, col] }
    end
    plant_bombs
  end

  def plant_bombs
    bomb_total.times do
      rand_pos = nil
      until rand_pos && self[rand_pos].clear?
        rand_pos = Array.new(2) { rand(size) }
      end

      self[rand_pos].plant_bomb
    end
  end

  def tiles
    Enumerator.new do |yielder|
      grid.each do |row|
        row.each do |tile|
          yielder << tile
        end
      end
    end
  end

  def validate_bomb_total
    max_bomb_total = size ** 2 - 2
    if bomb_total > max_bomb_total
      raise BombOverflow,
        "Too many bombs (#{bomb_total}) for board size (#{size}). "\
        "Allow at least two clear positions "\
        "(i.e. #{max_bomb_total} bombs or fewer)."
    end
  end
end
