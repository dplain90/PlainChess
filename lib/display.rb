
TOP_BANNER = "
  <div class=\"banner\">
    <h2 class=\"banner-title plain\">Plain</h2>
    <img src=\"/assets/images/castle.png\"> </img>
    <h2 class=\"banner-title chess\">Chess</h2>
    <div id=\"messages\">
      <div class=\"bottom-console\">
        <input type=\"text\" id=\"console\"></input>
        <ul class=\"instructions\">
          <li>
            <div class=\"command title\"> /1p </div>
            <div class=\"command\">1 player game</div>
          </li>
          <li>
            <div class=\"command title\"> /2p </div>
            <div class=\"command\">2 player game</div>
          </li>
        </ul>
      </div>
    </div>
  </div>
"

class Display
  attr_accessor :board
  def initialize(board)
    @html_response = TOP_BANNER + "<div class='board'>"
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

  def letter_keys
    top_header = "<div class='main'>"
    top_header_nums = (0..7).to_a.map do |num|
      "<div class='colHeader'>#{@grid_letters[num]}</div>"
    end

    return "
      #{top_header}
      <div class='topHeader'>
        <div class='colHeader'></div>
        #{top_header_nums.join}
      </div>"
  end



  def render
    board.grid.each_with_index do |row, row_idx|
      @html_response << "
      <div class='row'>
        <div class='rowHeader'>
          #{8 - row_idx}
        </div>
        #{board_row(row, row_idx)}
      </div>"
    end
    @html_response << letter_keys
    @html_response
  end

  def board_row(row_obj, row_idx)
    row = row_obj.map.with_index do |piece, col_idx|
      "
        <div class='space #{row_idx.to_s}-#{col_idx.to_s}'> #{piece.to_img}
        </div>
      "
    end

    row.join("")
  end
end
