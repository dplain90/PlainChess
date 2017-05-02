require_relative 'piece'

class Bishop < Piece
  include SlidablePiece
  attr_reader :directions, :color, :board

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @directions = {
      diag_left_up: [1, -1],
      diag_left_down: [-1, -1],
      diag_right_up: [1, 1],
      diag_right_down: [-1, 1]
     }
  end

end
