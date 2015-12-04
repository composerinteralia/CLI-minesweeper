require_relative "tile"

class Board
  attr_reader :grid, :size

  def initialize(size = 9)
    @size = size
    @grid = generate_grid(size)

    place_bombs(10)
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

  def render
    puts "   #{(0...size).to_a.join(" ")}"

    grid.each_with_index do |row, idx|
      print "#{idx}: "
      puts row.map(&:to_s).join(" ")
    end

    nil
  end

  def [](pos)
    row, col = pos
    grid[row][col]
  end
end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  board.render
  board[[4,4]].reveal
  board.render
end
