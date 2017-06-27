
require_relative 'piece'


class Rook < Piece
  attr_reader :directions, :color, :board, :point_count

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @point_count = 5
    @directions = {up: [1, 0], down: [-1, 0], left: [0, -1], right: [0, 1] }

  end
end
