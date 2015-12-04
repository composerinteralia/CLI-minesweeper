class Board
  attr_reader :grid

  def initialize(size = 9)
    @grid = Array.new(size) { Array.new(size) }
    populate
  end

  def populate
    grid.map!.with_index do |row, row_i|
      row.map!.with_index { |tile, col_i| Tile.new(:bomb, [row_i, col_i], self) }
    end
  end

  def render
    puts "   #{(0...grid.size).to_a.join(" ")}"

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
