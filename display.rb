require_relative "cursorable"

class Display
  include Cursorable

  attr_accessor :cursor_pos
  attr_reader :board

  def initialize(board, cursor_pos = [0, 0])
    @board = board
    @cursor_pos = cursor_pos
  end

  def render
    system("clear")
    puts "#{board.remaining_bombs_s} bombs remaining\n\n"

    puts_grid

    puts "\nPress 'r' to reveal and 'f' to flag\n\n"
  end

  private

  def puts_grid
    board.grid.each_with_index do |row, row_i|
      puts build_row(row, row_i).join(" ")
    end
  end

  def build_row(row, i)
    row.map.with_index do |tile, j|
      if [i, j] == cursor_pos
        tile.to_s.on_white
      else
        tile.to_s
      end
    end
  end

end
