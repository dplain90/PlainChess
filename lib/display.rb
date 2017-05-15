require 'colorize'
require 'json'

class Display
  attr_accessor :board
  def initialize(board)
    @html_response = "<div class='board'>"
    @board = board
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
end
