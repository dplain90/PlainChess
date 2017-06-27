
require_relative 'piece'

class Pawn < Piece
  attr_accessor :directions
  attr_reader :start_row, :color, :board, :point_count

  def initialize(symbol, board, color)
    super(symbol, board, color)
    @point_count = 1
    # @start_row = color == :white ? 1 : 6
    if color == :white
      @start_row = 6
      @directions = {
        up_two: [-2, 0],
        up: [-1, 0],
        up_right: [-1, 1],
        up_left: [-1, -1]
         }
    else
      @start_row = 1
      @directions = {
        up_two: [2, 0],
        up: [1, 0],
        up_right: [1, 1],
        up_left: [1, -1]
      }
    end
  end

  def invalid_pawn_check?(king_pos)
     king_pos == pos_in_front
  end

  def valid_up_two?(up, up_two)
    board.null_piece?(up) && board.null_piece?(up_two) && position.first == @start_row
  end

  def pos_in_front
    calc_new_pos(position, @directions[:up])
  end

  def candidates(pos, dir, results = [])
    new_pos = calc_new_pos(pos, dir)
    return [] if off_board?(new_pos) || same_color?(new_pos) || position.nil?
    if dir.first == 2 || dir.first == -2
      if valid_up_two?(pos_in_front, new_pos)
        [new_pos]
      else
        []
      end
    elsif dir.last != 0
      board.color_of_position(new_pos) == enemy_color ? [new_pos] : []
    else
      board.null_piece?(pos_in_front) ? [new_pos] : []
    end
  end

end
