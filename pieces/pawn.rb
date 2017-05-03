
require_relative 'piece'

class Pawn < Piece
  attr_accessor :directions
  attr_reader :start_row, :color, :board

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @start_row = color == :white ? 1 : 6
    if color == :white
      @start_row = 1
      @directions = {
        up_two: [2, 0],
        up: [1, 0],
        up_right: [1, 1],
        up_left: [1, -1]
      }
    else
      @start_row = 6
      @directions = {
        up_two: [-2, 0],
        up: [-1, 0],
        up_right: [-1, 1],
        up_left: [-1, -1]
         }
    end
  end

  def candidates(pos, dir, results = [])
    new_pos = calc_new_pos(pos, dir)
    return [] if off_board?(new_pos) || same_color?(new_pos)

    if dir.first == (2 || -2)
      position.first == start_row ? [new_pos] : []
    elsif dir.last != 0
      board.color_of_position(new_pos) == enemy_color ? [new_pos] : []
    else
      [new_pos]
    end
  end

end
