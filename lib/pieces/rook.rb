
require_relative 'piece'


class Rook < Piece
  attr_reader :directions, :color, :board, :point_count
  attr_accessor :castle
  def initialize(symbol, board, color)
    super(symbol, board, color)
    @castle = true
    @point_count = 5
    @directions = {up: [1, 0], down: [-1, 0], left: [0, -1], right: [0, 1] }
  end

  def can_castle(k)
    castle && k.castle
  end

  def castle_fen
    x = self.position.first
    if x < 1
      self.color == :white ? "Q" : "q"
    else
      self.color == :white ? "K" : "k"
    end
  end

  def no_castle_blocks(king)
    board.check_for_castle(self.position, king.position)
  end

  def no_check
    !board.in_check(self.color)
  end

  def castle_status(k)
    return true if can_castle(k) && no_castle_blocks(k) && no_check
    false
  end

end
