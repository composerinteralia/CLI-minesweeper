class BoardSizeError < StandardError
end

class BombOverflow < StandardError
end

class Board
  attr_reader :grid, :size, :num_bombs

  def initialize(size = 9, num_bombs = 10)
    unless size.between?(2, 36)
      raise BoardSizeError, "Board size must be between 2 and 36."
    end

    max_num_bombs = size ** 2 - 2
    if num_bombs > max_num_bombs
      raise BombOverflow,
        "Too many bombs (#{num_bombs}) for board size (#{size}). "\
        "Allow at least two clear positions "\
        "(i.e. #{max_num_bombs} bombs or fewer)."
    end

    @size = size
    @grid = generate_grid(size)
    @num_bombs = num_bombs
    place_bombs(num_bombs)
  end

  def generate_grid(size)
    (0...size).map do |row_i|
      (0...size).map { |col_i| Tile.new([row_i, col_i], self) }
    end
  end

  def place_bombs(num_bombs)
    num_bombs.times do
      x = rand(size)
      y = rand(size)

      until self[[x, y]].clear?
        x = rand(size)
        y = rand(size)
      end

      self[[x, y]].place_bomb
    end
  end

  def make_move(position, move_type)
    if move_type == :f
      return if self[position].revealed?
      self[position].flag
    elsif move_type == :r
      self[position].reveal
    end
  end

  def render
    system "clear"

    puts "#{remaining_bombs} bombs remaining"
    puts

    row_indices = (0...size).map { |n| n.to_s(36) }.join " "
    puts "  #{row_indices}"

    grid.each_with_index do |row, idx|
      print "#{idx.to_s(36)} "
      puts row.map(&:to_s).join " "
    end
    puts
  end

  def losing_render
    reveal_all
    render
  end

  def winning_render
    reveal_unflagged_bombs
    render
  end

  def reveal_all
    grid_each { |tile| tile.final_reveal }
  end

  def reveal_unflagged_bombs
    grid_each { |tile| tile.final_reveal unless tile.flagged? }
  end

  def grid_each
    grid.each do |row|
      row.each do |tile|
        yield tile
      end
    end
  end

  def won?
    grid.flatten.all? { |tile| tile.revealed? || tile.bomb? }
  end

  def remaining_bombs
    flagged_bombs = grid.flatten.count { |tile| tile.flagged? }
    bombs = num_bombs - flagged_bombs
    bombs < 0 ? bombs.to_s.red : bombs.to_s.green
  end

  def [](pos)
    row, col = pos
    grid[row][col]
  end
end
