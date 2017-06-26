require_relative 'pieces/piece'
require_relative 'display'
require_relative 'pieces/bishop'
require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/nullpiece'
require_relative 'pieces/pawn'
require_relative 'pieces/queen'
require_relative 'pieces/rook'



class Board
  attr_accessor :grid, :display

  def initialize(grid = Board.default_grid)
    @grid = grid
    populate_grid
  end

  def []=(pos, val)
    row, col = pos
    @grid[row][col] = val
  end

  def find_position(piece)
    self.grid.each_with_index do |row, row_idx|
      row.each_with_index do |col, col_idx|
        return [row_idx, col_idx] if self[[row_idx, col_idx]] == piece
      end
    end
    nil
  end

  def color_of_position(pos)
    self[pos].color
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def in_bounds!(pos)
    unless in_bounds?(pos)
      raise OutOfBoundsError.new "Your cursor is out of bounds!"
    end
  end

  def in_bounds?(pos)
    pos.all? { |axis| axis.between?(0,7) }
  end

  def move_piece(pos, color)
    start_pos, end_pos = pos
    validate_move!(start_pos, end_pos, color)
    swap!(start_pos, end_pos)
  end

  def validate_move!(start_pos, end_pos, color)
    has_piece!(start_pos)
    moving_own_piece!(start_pos, color)
    valid_piece_move!(start_pos, end_pos)
    not_in_check!(start_pos, end_pos, color)
  end

  def not_in_check!(start_pos, end_pos, color)
    raise InCheckError.new "Can't do that because of check!" if
    result_in_check(start_pos, end_pos, color)
  end

  def valid_piece_move!(start_pos, end_pos)
    puts self[start_pos].valid_moves
    raise InvalidMoveError.new "That piece can't move there! #{self[start_pos].valid_moves}" if !self[start_pos].valid_moves[end_pos]
  end

  def moving_own_piece!(pos, color)
    raise WrongColorError.new "That is not your piece!" if !in_bounds?(pos) || color_of_position(pos) != color
  end

  def has_piece!(pos)
    raise NoStartPieceError.new "This space has no piece!" if self[pos].is_a?(NullPiece)
  end

  def result_in_check(pos, new_pos, color)
    swap!(pos, new_pos)
    outcome = in_check?(color)
    swap!(new_pos, pos)
    outcome
  end

  def swap!(pos, new_pos)
    self[new_pos] = self[pos]
    self[pos] = NullPiece.instance
  end

  def safe_moves?(piece)
    piece.moves.any? do |move|
      !result_in_check(piece.position, move, piece.color)
    end
  end

  def enemy_color(color)
    color == :white ? :black : :white
  end

  def checkmate?(color)
    !all_pieces(color).any?{ |piece| safe_moves?(piece)}  && in_check?(color)
  end

  def in_check?(color)
    king = find_king(color).first
    Piece.all_moves(king.enemy_color).include?(king.position)
  end

  def all_pieces(color)
    Piece.all_pieces(color)
  end

  def find_king(color)
    all_pieces(color).select{|piece| piece.is_a?(King)}
  end

  def find_board
    board.grid.each do |row|
      board = row.select{|piece| piece.is_a?(Board)}
      return board.first unless board.empty?
    end
  end

  def self.default_grid
    Array.new(8) { Array.new(8) }
  end

  def populate_pawns
    pawn_rows = [[1, :black],[-2, :white]].each do |side|
      row_idx = side.first
      color = side.last
      grid[row_idx].each_index do |col_idx|
        self[[row_idx, col_idx]] = Pawn.new(:p, board, color)
      end
    end
  end

  def populate_other_pieces
    # side = [[0, :white],[-1, :black]]
    side = [[0, :black], [-1, :white]]
      side.each do |side|
        row_idx = side.first
        color = side.last
        grid[row_idx].each_index do |i|
          case i
          when 0
            self[[row_idx, i]] = Rook.new(:r, board, color)
          when 1
            self[[row_idx, i]] = Knight.new(:h, board, color)
          when 2
            self[[row_idx, i]] = Bishop.new(:b, board, color)
          when 3
            self[[row_idx, i]] = Queen.new(:q, board, color)
          when 4
            self[[row_idx, i]] = King.new(:k, board, color)
          when 5
            self[[row_idx, i]] = Bishop.new(:b, board, color)
          when 6
            self[[row_idx, i]] = Knight.new(:h, board, color)
          when 7
            self[[row_idx, i]] = Rook.new(:r, board, color)
          end
      end
    end
  end

  def populate_nil_pieces
    (2..5).to_a.each do |row_idx|
      grid[row_idx].each_index do |col_idx|
        self[[row_idx, col_idx]] = NullPiece.instance
      end
    end
  end

  def populate_grid
    populate_other_pieces
    populate_nil_pieces
    populate_pawns
  end

  private

  def board
    self
  end

end

class NoStartPieceError < ArgumentError
end

class InvalidMoveError < ArgumentError
end

class OutOfBoundsError < ArgumentError
end

class WrongColorError < ArgumentError
end

class InCheckError < ArgumentError
end
