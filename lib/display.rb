require 'colorize'
require_relative 'cursor'
require 'json'

class Display

  attr_accessor :board, :cursor
  def initialize(board)
    @html_response = "<div class='board'>"
    @board = board
    @cursor = Cursor.new([0,0], board)

    @grid_letters = {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D',
      4 => 'E',
      5 => 'F',
      6 => 'G',
      7 => 'H'
    }
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

  def top_header_html
    top_header = "<div class='board main'>"
    top_header_nums = (0..7).to_a.map do |num|
      "<div class='colHeader'>#{@grid_letters[num]}</div>"
    end

    return "#{top_header}<div class='topHeader'><div class='colHeader'></div>#{top_header_nums.join}</div>"
  end

  def render
    @html_response << top_header_html
    puts "   #{(0..7).to_a.join(' ')}"
    board.grid.each_with_index do |row, row_idx|
      row_string = create_row(row, row_idx)
      puts "#{row_idx}| #{row_string.join(" ")}"
      @html_response << "<div class='row'><div class='rowHeader'>#{row_idx}</div>#{html_row_string(row, row_idx)}</div>"
    end

    @html_response
  end

  def html_row_string(row, row_idx)
    html_row = row.map.with_index do |piece, col_idx|
      "<div class='space #{row_idx.to_s}-#{col_idx.to_s}'> #{piece.to_str} </div>"
    end

    html_row.join("")
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
