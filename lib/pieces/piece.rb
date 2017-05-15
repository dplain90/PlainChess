class Piece
  @@black_pieces = []
  @@white_pieces = []

  attr_accessor :symbol, :board, :color

  def initialize(symbol, board, color)
    @symbol = symbol
    @board = board
    @color = color
    @color == :white ? @@white_pieces << self : @@black_pieces << self
  end

  def self.all_pieces(color)
    color == :white ? @@white_pieces : @@black_pieces
  end

  def self.all_moves(color)
    Piece.all_pieces(color).map{ |piece| piece.moves }.flatten(1)
  end

  def to_str
    if symbol == :n
      " "
    else
      symbol.to_s
    end
  end

  def same_color?(pos)
    board.color_of_position(pos) == @color
  end

  def off_board?(pos)
    !board.in_bounds?(pos)
  end

  def candidates(pos, dir, results = [])
    pos = calc_new_pos(pos, dir) if pos == position
    return results if off_board?(pos) || same_color?(pos)
    results << pos
    return results if board.color_of_position(pos) == enemy_color
    candidates(calc_new_pos(pos, dir), dir, results)
  end

  def calc_new_pos(pos, incr)
    pos.zip(incr).map {|num| num.inject(:+)}
  end

  def moves
    self.directions
      .values
      .map{ |dir| candidates(position, dir) }
      .flatten(1)
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
