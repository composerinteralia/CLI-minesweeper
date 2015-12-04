class Board
  attr_reader :grid

  def initialize(size = 9)
    @grid = Array.new(size) { Array.new(size) }
    populate
  end

  def populate
    grid.map! do |row|
      row.map! { |tile| Tile.new(:bomb) }
    end
  end

end
