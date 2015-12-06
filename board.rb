class Board
  class SizeError < StandardError
  end

  class BombOverflow < StandardError
  end

  attr_reader :size, :bomb_total

  def initialize(size = 9, bomb_total = 10)
    validate size, bomb_total
    @size = size
    @bomb_total = bomb_total

    @grid = generate_grid size
    place_bombs bomb_total
  end

  def [](pos)
    row, col = pos
    grid[row][col]
  end

  def losing_render
    reveal_all
    render
  end

  def move(position, move_type)
    tile = self[position]

    tile.flag if move_type == :f && !tile.revealed?
    tile.reveal if move_type == :r
  end

  def render
    system "clear"

    print "#{remaining_bombs} bombs remaining\n\n"

    row_indices = (0...size).map { |row_i| row_i.to_s(36) }
    puts "  " << row_indices.join(" ")

    grid.each_with_index do |row, col_i|
      print col_i.to_s(36) << " "
      puts row.map(&:to_s).join(" ")
    end
    puts
  end

  def winning_render
    reveal_unflagged_bombs
    render
  end

  def won?
    tiles.all? { |tile| tile.revealed? || tile.bomb? }
  end

  private
  attr_reader :grid

  def generate_grid(size)
    indices = (0...size)
    indices.map do |row_i|
      indices.map { |col_i| Tile.new [row_i, col_i], self }
    end
  end

  def place_bombs(bomb_total)
    bomb_total.times do
      row, col = rand(size), rand(size)
      until self[[row, col]].clear?
        row, col = rand(size), rand(size)
      end

      self[[row, col]].place_bomb
    end
  end

  def remaining_bombs
    flagged_bombs = tiles.count { |tile| tile.flagged? }
    bombs = bomb_total - flagged_bombs
    bombs < 0 ? bombs.to_s.red : bombs.to_s.green
  end

  def reveal_all
    tiles.each { |tile| tile.reveal_self }
  end

  def reveal_unflagged_bombs
    tiles.each { |tile| tile.reveal_self unless tile.flagged? }
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

  def validate(size, bomb_total)
    unless size.between? 2, 36
      raise SizeError, "Board size must be between 2 and 36."
    end

    max_bomb_total = size ** 2 - 2
    if bomb_total > max_bomb_total
      raise BombOverflow,
        "Too many bombs (#{bomb_total}) for board size (#{size}). "\
        "Allow at least two clear positions "\
        "(i.e. #{max_bomb_total} bombs or fewer)."
    end
  end

end
