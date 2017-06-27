require_relative 'piece'

class Bishop < Piece
  attr_reader :directions, :color, :board, :point_count

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @point_count = 3
    @directions = {
      diag_left_up: [1, -1],
      diag_left_down: [-1, -1],
      diag_right_up: [1, 1],
      diag_right_down: [-1, 1]
     }
  end

end
