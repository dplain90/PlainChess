require_relative 'piece'

class Queen < Piece
  attr_reader :directions, :color, :board

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @directions = {
      up: [1, 0],
      down: [-1, 0],
      left: [0, -1],
      right: [0, 1],
      diag_left_up: [1, -1],
      diag_left_down: [-1, -1],
      diag_right_up: [1, 1],
      diag_right_down: [-1, 1]
     }
  end

end
