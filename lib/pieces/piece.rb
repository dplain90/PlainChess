
class Piece
  @@black_pieces = []
  @@white_pieces = []

  attr_accessor :symbol, :board, :color, :active

  def initialize(symbol, board, color)
    @active = true
    @symbol = symbol
    @board = board
    @color = color
    @color == :white ? @@white_pieces << self : @@black_pieces << self
  end

  def self.all_pieces(color)
    color == :white ? @@white_pieces : @@black_pieces
  end

  def self.all_moves(color, prc = Proc.new { |piece| piece.moves })
    Piece.all_pieces(color).map{ |piece| prc.call(piece) }.flatten(1)
  end

  def to_str
    if symbol == :n
      " "
    else
      symbol.to_s
    end
  end

  def to_img
    return "" if symbol == :n
    "
    <img id=\"#{self.to_str}\" src=\"/assets/images/#{self.to_str}-#{color.to_s}.png\">
    </img>
    "
  end

  def img_path
    return "" if symbol == :n
    "\"/assets/images/#{self.to_str}-#{color.to_s}.png\""
  end

  def same_color?(pos)
    return false if pos == []
    board.color_of_position(pos) == @color
  end

  def off_board?(pos)
    !board.in_bounds?(pos)
  end

  def candidates(pos, dir, results = [])
    return [] if pos.nil?
    pos = calc_new_pos(pos, dir) if pos == position
    return results if off_board?(pos) || same_color?(pos)
    results << pos
    return results if board.color_of_position(pos) == enemy_color
    candidates(calc_new_pos(pos, dir), dir, results)
  end

  def calc_new_pos(pos, incr)
    return [] if pos == nil
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

  def is_enemy?(piece)
    enemy_color == piece.color
  end
end
