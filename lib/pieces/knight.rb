require_relative 'piece'

class Knight < Piece
  attr_reader :directions, :color, :board, :point_count

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @point_count = 3
    @directions = {
      down_right: [-2, 1],
      down_left: [-2, -1],
      up_right: [2, 1],
      up_left: [2, -1],
      right_down: [-1, 2],
      right_up: [1, 2],
      left_down: [1, -2],
      left_up: [-1, -2]
     }
  end

  def candidates(pos, dir, results = [])
    return [] if pos.nil?
    new_pos = calc_new_pos(pos, dir)
    off_board?(new_pos) || same_color?(new_pos) ? [] : [new_pos]
  end

end
