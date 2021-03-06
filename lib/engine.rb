require_relative 'player'
require_relative 'pieces/piece'
require 'stockfish'
class Engine < Player
  attr_accessor :board, :moves, :top_move
  def initialize(color, board)
    super(color)
    @board = board
    @moves = Piece.all_moves(color)
    @most_space = calc_space
    @most_pts = score
    @engine = Stockfish::Engine.new("~/bin/stockfish_8_x64")
    @engine.multipv(3)
  end

  def enemy_color
    color == :white ? :black : :white
  end

  def enemy_moves
    get_moves(enemy_color)
  end

  def decide_move(fen)
    column_key = {}
    ('a'..'h').to_a.each_with_index do |letter, i|
      column_key[letter] = i
    end

    best_move = @engine.analyze fen, { depth: 12 }
    m = best_move.split('bestmove')[-1].split('ponder')[0].strip
    start_pos = [ 8 - m[1].to_i, column_key[m[0]]]
    end_pos = [ 8 - m[3].to_i, column_key[m[2]]]
    [start_pos, end_pos]
  end

  def handle_move(fen)
    decide_move(fen)
  end

  def get_pieces(clr)
    callback = Proc.new { |piece| piece }
    Piece.all_moves(clr, callback)
  end

  def find_move(clr, prc)
    found_moves = []
    get_pieces(clr).each do |piece|
      found_moves << find_candidates(piece, prc)
    end


    found_moves.flatten(1)
  end

  def find_candidates(piece, prc)
    found_moves = []
    piece.moves.each do |move|

       if prc.call(piece.position, move)

         found_moves << [piece.position, move]
       end
    end
    found_moves
  end

  def will_check(pos, new_pos, color)
    self.board.result_in_check(pos, new_pos, color)
  end

  def check_moves
    callback = Proc.new do |piece, move|
      pos = piece.position
      will_check(pos, move, enemy_color)
    end

    find_move(callback)
  end

  def switch_check(pos, new_pos, prc)
    taken = board.switch!(pos, new_pos)
    outcome = prc.call(pos, new_pos)
    board.switch_back!(pos, new_pos, taken)
    outcome
  end
  #
  def checkmate_moves
    candidate_pieces = check_moves
    results = []
    return nil if candidate_pieces == []
    is_mated = Proc.new { |board| board.checkmate?(enemy_color) }
    candidate_pieces.each do |candidate|
      piece, checks = candidate
      check_for_mate = Proc.new do |move|
        switch_check(piece.position, move, is_mated)
      end

      results << find_candidates(checks, check_for_mate)
    end
    results
  end

  def calc_space
    engine_moves = Piece.all_moves(color).length

    enemy_moves = Piece.all_moves(enemy_color).length

    engine_moves.to_f / enemy_moves
  end


  def calc_points(clr)
    total = 0
    Piece.all_pieces(clr).each do |piece|
      total += piece.point_count if piece.active
    end
    total
  end

  def score
    raw = calc_points(self.color) - calc_points(enemy_color)
    point_score = 100 + raw
    point_score + (point_score * calc_space)
  end

  def create_space_move
    check_space = Proc.new do |pos, new_pos|
      if @most_pts <= score
        @most_pts = score
        true
      else
        false
      end
    end
    check_space_size = Proc.new do |current_pos, next_pos|

      if switch_check(current_pos, next_pos, check_space)
        begin
          board.validate_move!(current_pos, next_pos, color)
          @top_move = [current_pos, next_pos]
          true
        rescue
          false
        end
      else
        false
      end
    end

    find_move(color, check_space_size)
  end

end
