
require_relative 'piece'


class Rook < Piece
  include SlidablePiece
  attr_reader :directions, :color, :board

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @directions = {up: [1, 0], down: [-1, 0], left: [0, -1], right: [0, 1] }

  end
end
