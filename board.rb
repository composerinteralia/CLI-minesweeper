require_relative "tile"

class Board
  attr_reader :grid, :size

  def initialize(size = 9)
    @size = size
    @grid = Array.new(size) { Array.new(size) }

    populate
    place_bombs(10)
  end

  def populate
    grid.map!.with_index do |row, row_i|
      row.map!.with_index { |tile, col_i| Tile.new([row_i, col_i], self) }
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

  def reveal_all
    grid.each do |row|
      row.each do |tile|
        tile.reveal
      end
    end
  end

  def [](pos)
    row, col = pos
    grid[row][col]
  end
end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  board.reveal_all
  board.render
end
