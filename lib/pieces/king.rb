require_relative 'piece'

class King < Piece
  attr_reader :directions, :color, :board, :point_count, :active
  attr_accessor :castle

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @active = true
    @castle = true
    @point_count = 20
    @directions = {
      up: [1, 0],
      down: [-1, 0],
      left: [0, -1],
      right: [0, 1],
      diag_left_up: [-1, -1],
      diag_left_down: [1, -1],
      diag_right_up: [-1, 1],
      diag_right_down: [1, 1]
     }
  end

  def candidates(pos, dir, results = [])
    new_pos = calc_new_pos(pos, dir)
    off_board?(new_pos) || same_color?(new_pos) ? [] : [new_pos]
  end


end
