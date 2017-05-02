require 'colorize'
require_relative 'cursor'


class Display

  attr_accessor :board, :cursor
  def initialize(board)
    @board = board
    @cursor = Cursor.new([0,0], board)
  end

  def reset_move
    cursor.move_input = []
  end

  def move
    until cursor.move_input.length == 2
      move_input = cursor.move_input
      begin
        cursor.get_input
        system "clear"
        render
      rescue OutOfBoundsError => e
        puts "#{e.message}"
        retry
      end
    end

    move_input
  end

  def render
    puts "   #{(0..7).to_a.join(' ')}"
    board.grid.each_with_index do |row, row_idx|
      row_string = create_row(row, row_idx)
      puts "#{row_idx}| #{row_string.join(" ")}"
    end
  end

  def create_row(row, row_idx)
    row.map.with_index do |piece, col_idx|
      if [row_idx, col_idx] == cursor.cursor_pos
        piece.to_str.colorize(:blue)
      else
        piece.to_str
      end
    end
  end

end
