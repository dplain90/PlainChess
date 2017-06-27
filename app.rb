require_relative './game'
require 'rack'
require 'erb'
require 'byebug'
DEFAULT_PROMPT = " player game initiated, you are white. It's your move!"

class App
  attr_accessor :game, :player_qty, :rendered
  def initialize
    @rendered = 0
    @game = Game.new(1)
    @player_qty
  end

  def generate_html(board)
    index = File.open('index.html')
    index_arr = index.read.split('<body>')
    index.close
    return [index_arr[0], '<body>', board ,'</div>', index_arr[1]].join
  end

  def insert_error(error, resp)
    msg_div = "<div id=\"messages\">"
    error = "<div class=\"errors\">" + error + "</div>"
    resp_arr = resp.split(msg_div)
    [resp_arr[0], msg_div, error, resp_arr[1]].join
  end


  def player_game(num, prompt = DEFAULT_PROMPT)
    Proc.new do |env|
      req = Rack::Request.new(env)
      res = Rack::Response.new
      num_str = num == 1 ? "One" : "Two"
      prompt_str = "#{num_str}" + prompt
      @game = Game.new(num)
      @player_qty = num
      html_resp = generate_html(@game.display.render)
      rendered_html = insert_error(prompt_str, html_resp)
      res['Content-Type'] = 'text/html'
      res.write(rendered_html)


      res.finish
    end
  end

  def reset
    prompt = " player game reset. You are white. Your move!"
    player_game(@player_qty, prompt)
  end

  def gameplay
    Proc.new do |env|
      req = Rack::Request.new(env)
      res = Rack::Response.new

      if req.request_method == "POST"
        res['Content-Type'] = 'application/json'
        move = JSON.parse(req.body.read)["move"]
        move = game.play_move(move).merge({players: @player_qty})
        res.write(JSON.generate(move))
        res.finish
      else
    # elsif @rendered == 0
        # @rendered += 1
        res['Content-Type'] = 'text/html'
        my_test = generate_html(game.display.render)
        res.write(my_test)
        res.finish
      end
      # else
      #   res['Content-Type'] = 'text/html'
      #   indexPage = File.open('index.html')
      #   res.write(indexPage.read)
      #   indexPage.close
      #   res.finish
      # end
    end
  end
end

main = App.new
# builder = Rack::Builder.new do
#   use Rack::Static, :urls => ["/assets/css", "/assets/images", "/assets/js"]
#   map '/' do
#     run main.gameplay
#   end
#
#   map '/1p' do
#     run main.player_game(1)
#   end
#
#   map '/2p' do
#     run main.player_game(2)
#   end
#
#   map '/r' do
#     run main.reset
#   end
# end
#
# Rack::Server.start(
# app: builder,
# Port: 3000
# )
