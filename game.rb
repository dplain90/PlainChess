require_relative 'display'
require_relative 'board'
require_relative 'player'
require 'byebug'
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

game = Game.new
game.play
