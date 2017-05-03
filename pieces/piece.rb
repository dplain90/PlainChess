require 'byebug'
module SlidablePiece

  def moves
    candidate_moves = []

    directions.values.each do |direction|
      candidate_moves += move_dirs(position, direction)
    end

    candidate_moves
  end

  def calculate_new_position(start_pos, incrementer)
    start_x, start_y = start_pos
    increment_x, increment_y = incrementer
    [start_x + increment_x, start_y + increment_y]
  end

  def horizontal_dirs
  end

  def move_dirs(starting_pos, direction)
    new_position = starting_pos
    position_color = color

    result = []

    until position_color == enemy_color
      new_position = calculate_new_position(new_position, direction) #increment pos
      break unless board.in_bounds?(new_position) # make sure pos in bounds
      position_color = board.color_of_position(new_position)
      break if position_color == color
      result << new_position
    end

    result
  end

end

module SteppablePiece

    def moves
      candidate_moves = []

      self.directions.values.each do |direction|
        candidate_moves += move_dirs(position, direction)
      end

      candidate_moves
    end

    def calculate_new_position(start_pos, incrementer)
      start_x, start_y = start_pos
      increment_x, increment_y = incrementer

      [start_x + increment_x, start_y + increment_y]
    end

    def move_dirs(starting_pos, direction)
      new_position = starting_pos
      position_color = color

      result = []

      until starting_pos != new_position
        new_position = calculate_new_position(new_position, direction) #increment pos
        break unless board.in_bounds?(new_position) # make sure pos in bounds
        position_color = board.color_of_position(new_position)
        break if position_color == color
        result << new_position
      end

      result
    end
end

module Nullable
end

module PawnPiece
end

class Piece

  attr_accessor :symbol, :board, :color

  def initialize(symbol, board, color)
    @symbol = symbol
    @board = board
    @color = color
  end

  def to_str
    if symbol == :n
      " "
    else
      symbol.to_s
    end
  end

  def valid_moves
    candidate_moves = {}
    if self.is_a?(Pawn)
      color == :white ? self.directions = @white_directions : self.directions = @black_directions
    end
    moves.each { |move| candidate_moves[move] = true }
    candidate_moves
  end


  def position
    board.find_position(self)
  end


  private

  def enemy_color
    color == :white ? :black : :white
  end

end
