require_relative 'display'
require_relative 'board'
require_relative 'player'

require 'byebug'
require 'rack'
require 'erb'
class Game
  attr_reader :board, :display, :p1, :p2
  attr_accessor :current_player
  def initialize
    @board = Board.new
    @display = Display.new(@board)
    @p1 = Player.new(:black)
    @p2 = Player.new(:white)
    @current_player = @p1
  end

  def play_move(move)
    start_pos, end_pos = move
    board.move_piece(move, current_player.color)
    swap_turn!
    return {
      'start_val' => self.board[start_pos].to_str,
      'end_val' => self.board[end_pos].to_str
      }
  end

  def play
    until black_checkmated? || white_checkmated?
      begin
        board.move_piece(display.move, current_player.color)
        display.reset_move
        swap_turn!
        system "clear"
        display.render
      rescue WrongColorError, NoStartPieceError, InvalidMoveError, InCheckError => e
        puts "#{e.message}"
        display.reset_move
        retry
      end
    end
    notify_players
  end


  private
  def black_checkmated?
    board.checkmate?(:black)
  end

  def white_checkmated?
    board.checkmate?(:white)
  end

  def notify_players
    if black_checkmated?
      puts "White wins!"
    else
      puts "Black wins!"
    end
  end


  def swap_turn!
    if @current_player == @p1
       @current_player = @p2
    else
      @current_player = @p1
    end
  end
end
require 'rack'


def generate_html(board)

  index = File.open('index.html')
  index_arr = index.read.split('<body>')
  index.close
  return [index_arr[0], '<body>', board ,'</div>', index_arr[1]].join
end
# html_str = game.display.render
game = Game.new
not_rendered = 0
app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new

  if req.request_method == "POST"
    res['Content-Type'] = 'application/json'
    move = JSON.parse(req.body.read)["move"]
    res.write(JSON.generate(game.play_move(move)))
    res.finish
  # elsif not_rendered == true
elsif not_rendered == 0
    not_rendered += 1
    res['Content-Type'] = 'text/html'
    my_test = generate_html(game.display.render)

    res.write(my_test)
    res.finish
    # not_rendered = false
  else
    res['Content-Type'] = 'text/html'
    indexPage = File.open('index.html')
    res.write(indexPage.read)
    indexPage.close
    res.finish
  end
end

# app = Rack::Builder.new do
#   use Rack::Static, :urls => ["/css", "/images", "/js"], :root => "public"
#   run app
# end.to_app


Rack::Server.start(
app: app,
Port: 3000
)
