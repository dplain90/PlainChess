require 'byebug'

class Piece
  @@black_pieces = []
  @@white_pieces = []

  attr_accessor :symbol, :board, :color

  def initialize(symbol, board, color)
    @symbol = symbol
    @board = board
    @color = color
    color == :white ? @@white_pieces << self : @@black_pieces << self
  end

  def self.all_pieces(color)
    color == :white ? @@white_pieces : @@black_pieces
  end

  def self.all_moves(color)
    Piece.all_pieces.map{ |piece| piece.moves }.flatten
  end

  def to_str
    if symbol == :n
      " "
    else
      symbol.to_s
    end
  end

  def same_color?(pos)
    board.color_of_position(pos) == color
  end

  def off_board?(pos)
    board.in_bounds?(pos)
  end

  def candidates(pos, dir, results)
    return results if off_board? || same_color?(pos) || condition

    results << starting_pos
    add_position(calc_new_pos(pos, dir), dir, results)
  end

  def calc_new_pos(pos, incr)
    pos.zip(incr).map {|num| num.inject(:+)}
  end

  def moves
    self.directions
      .values
      .map{ |dir| candidates(position, direction) }
      .flatten
  end

  def valid_moves
    candidate_moves = {}
    moves.each { |move| candidate_moves[move] = true }
    candidate_moves
  end

  def position
    board.find_position(self)
  end

  def enemy_color
    color == :white ? :black : :white
  end

end
