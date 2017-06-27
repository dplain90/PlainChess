require_relative './lib/display'
require_relative './lib/board'
require_relative './lib/player'
require_relative './lib/engine'

require 'rack'
require 'erb'
class Game
  attr_reader :board, :display, :p1, :p2, :p_qty
  attr_accessor :current_player
  def initialize(p_qty)
    @board = Board.new
    @display = Display.new(@board)
    if p_qty == 1
      @p1 = Engine.new(:black, @board)
    else
      @p1 = Player.new(:black)
    end
    @p2 = Player.new(:white)
    @p_qty = p_qty
    @current_player = @p2

  end

  def game_over?
    if self.black_checkmated?
      puts "White wins!"
      return "White wins!"
    elsif self.white_checkmated?
      return "Black wins!"
    else
      return ""
    end
  end

  def engine_move
    # @p1 = Engine.new(:black, @board)
    @p1.handle_move
  end

  def generate_response(start_pos, end_pos)
    resp = {
      'start_val' => self.board[start_pos].to_img,
      'end_val' => self.board[end_pos].to_img,
      'errors' => ""
    }
    if p_qty != 1
      resp
    else
      engine_start, engine_end = engine_move
      board.move_piece(engine_move, current_player.color)
      swap_turn!
      engine_resp = {
        'engine_pos_start' => engine_start,
        'engine_pos_end' => engine_end,
        'engine_start' => self.board[engine_start].to_img,
        'engine_end' => self.board[engine_end].to_img
      }

      resp.merge(engine_resp)
    end
  end

  def play_move(move)
    begin
      start_pos, end_pos = move
      board.move_piece(move, current_player.color)
      swap_turn!
      response = generate_response(start_pos, end_pos)
      response['winner'] = game_over?
      response
    rescue WrongColorError, NoStartPieceError, InvalidMoveError, InCheckError => e
      return {
        'errors' => e.message
      }
    end
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

  def black_checkmated?
    @board.checkmate?(:black)
  end

  def white_checkmated?
    @board.checkmate?(:white)
  end

  private

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
