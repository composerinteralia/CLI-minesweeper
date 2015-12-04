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

  def render
    puts "   #{(0...grid.size).to_a.join(" ")}"

    grid.each_with_index do |row, idx|
      print "#{idx}: "
      puts row.map(&:to_s).join(" ")
    end

    nil
  end

end
