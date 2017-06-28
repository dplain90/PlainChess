require_relative './game'
require 'rack'
require 'erb'
require 'byebug'
require 'json'
require 'open3'
require 'io/wait'
DEFAULT_PROMPT = " player game initiated, you are white. It's your move!"

class App
  attr_accessor :game, :player_qty, :rendered
  def initialize
    @rendered = 0
    @game = Game.new(1)
    @player_qty
    # engine = Stockfish::Engine.new("./bin/stockfish-8-64")
    # engine.multipv(3)
    # fen = "rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1"
    # puts engine.analyze fen, { :depth => 12 }
#     @stdin, @stdout, @stderr, @wait_threads = Open3.popen3(, "position fen )
#
#     @pid = @wait_threads[:pid]
#     p @stdout.read
#     p @stderr.read
#     @stdin.close  # stdin, stdout and stderr should be closed explicitly in this form.
# @stdout.close
# @stderr.close
    # @stdin.puts 'uci'
    # line = @stdout.readline
    # puts line
    # Open3.pipeline_r("heroku run stockfish uci",
    # "heroku run stockfish , "heroku run stockfish go depth 10") do |last_stdout, wait_threads|
    #   last_stdout.each_line do |line|
    #     puts last_stdout
    #     puts line
    #   end


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
    @player_qty = num
    Proc.new do |env|
      req = Rack::Request.new(env)
      res = Rack::Response.new
      num_str = num == 1 ? "One" : "Two"
      prompt_str = "#{num_str}" + prompt
      @player_qty = num
      @game = Game.new(num)
      html_resp = generate_html(@game.display.render)
      rendered_html = insert_error(prompt_str, html_resp)
      res['Content-Type'] = 'text/html'
      res.write(rendered_html)


      res.finish
    end
  end


  def gameplay
    Proc.new do |env|
      req = Rack::Request.new(env)
      res = Rack::Response.new

      if req.request_method == "POST"
        res['Content-Type'] = 'application/json'
        move = JSON.parse(req.body.read)["move"]
        outcome = @game.play_move(move).merge({players: @player_qty})
        res.write(JSON.generate(outcome))
        res.finish
      else
        game = Game.new(@player_qty)
        res['Content-Type'] = 'text/html'
        my_test = generate_html(game.display.render)
        res.write(my_test)
        res.finish
      end
    end
  end
end
