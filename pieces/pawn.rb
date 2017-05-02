
require_relative 'piece'


class Pawn < Piece
  include SteppablePiece
  attr_reader :directions, :white_directions, :black_directions, :color, :board

  def initialize(symbol, board, color)
    super(symbol, board, color)

    @black_directions = {
      up_two: [-2, 0],
      up: [-1, 0],
      up_right: [-1, 1],
      up_left: [-1, -1]
       }

     @white_directions = {
       up_two: [2, 0],
       up: [1, 0],
       up_right: [1, 1],
       up_left: [1, -1]

     }
    #  set_directions
  end

  def set_directions
    color == :white ? @directions = @white_directions : @directions = @black_directions
    starting_row = color == :white ? 1 : 6

    directions.each do |direction, increment|

      incr_pos = calculate_new_position(position, increment)

      next unless board.in_bounds?(incr_pos)
      incr_pos_color = board.color_of_position(incr_pos)
        case direction
          when :up_two
            up_two_delete(direction, starting_row, incr_pos_color)
          when :up
            up_delete(direction, incr_pos_color)
          when :up_right
            right_left_delete(direction, incr_pos_color)
          when :up_left
            right_left_delete(direction, incr_pos_color)
        end
    end
  end

  def up_delete(direction, incr_pos_color)
    directions.delete(direction) unless incr_pos_color.nil?
  end

  def up_two_delete(direction, starting_row, incr_pos_color)
    up_pos = calculate_new_position(position, directions[:up])
    up_pos_color = board.color_of_position(up_pos)
    directions.delete(direction) unless position.first == starting_row && incr_pos_color.nil? && up_pos_color.nil?
  end

  def right_left_delete(direction, incr_pos_color)
    directions.delete(direction) unless incr_pos_color == enemy_color
  end
end
