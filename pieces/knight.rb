require_relative 'piece'

class Knight < Piece
  include SteppablePiece
  attr_reader :directions, :color, :board

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @directions = {
      down_right: [-2, 1],
      down_left: [-2, -1],
      up_right: [2, 1],
      up_left: [2, -1],
      right_down: [-1, 2],
      right_up: [1, 2],
      left_down: [1, -2],
      left_up: [-1, -2],
     }
  end


end
