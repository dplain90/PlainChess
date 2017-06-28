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
  attr_accessor :grid, :display, :two_stepper, :half_clock

  def initialize(grid = Board.default_grid)
    @grid = grid
    @two_stepper = nil
    @half_clock = 0
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
    return false if pos.nil?
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
    if self[end_pos].color == enemy_color(color)
      self[end_pos].active = false
    end
    update_special_moves(start_pos, end_pos)
    swap!(start_pos, end_pos)
  end

  def update_special_moves(start_pos, end_pos)
    piece = self[start_pos]
    update_castle(piece)
    start_x = start_pos.first
    end_x = end_pos.first
    if piece.symbol == :p && (end_x - start_x).abs == 2
      self.two_stepper = piece
    else
      self.two_stepper = nil
    end
    puts self[end_pos]
    update_halfclock(piece, end_pos)
  end

  def update_halfclock(piece, end_pos)
    if piece.symbol == :p || !null_piece?(end_pos)
      self.half_clock = 0
    else
      self.half_clock += 1
    end
  end

  def update_castle(piece)
    piece.castle = false if piece.symbol == :k || piece.symbol == :r
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

    raise InvalidMoveError.new "That piece can't move there! #{self[start_pos].valid_moves}" if !self[start_pos].valid_moves[end_pos]
  end

  def moving_own_piece!(pos, color)
    raise WrongColorError.new "That is not your piece!" if !in_bounds?(pos) || color_of_position(pos) != color
  end

  def has_piece!(pos)
    raise NoStartPieceError.new "This space has no piece!" if self[pos].is_a?(NullPiece)
  end

  def result_in_check(pos, new_pos, color)
    taken_piece = switch!(pos, new_pos)
    outcome = in_check?(color)
    switch_back!(pos, new_pos, taken_piece)
    outcome
  end

  def switch_back!(pos, new_pos, taken_piece)
    swap!(new_pos, pos)
    taken_piece.active = true
    self[new_pos] = taken_piece
  end

  def switch!(pos, new_pos)
    if !null_piece?(new_pos)
      taken_piece = self[new_pos]
      taken_piece.active = false
    else
      taken_piece = NullPiece.instance
    end
    swap!(pos, new_pos)
    taken_piece
  end

  def null_piece?(pos)
    self[pos] == NullPiece.instance
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

  def to_notation(pos)
    rows = ('a'..'h').to_a.reverse
    x, y = pos
    rows[y] + (8 - x).to_s
  end

  def find_piece_type(color, sym)
    Piece.all_pieces(color).select do |piece|
      piece.symbol == sym && piece.active == true
    end
  end

  def passant_fen
    if !two_stepper.nil?
      return to_notation(two_stepper.position)
      two_stepper = nil
    end

    "-"
  end

  def castle_fen
    fen = ""
    [:black, :white].each do |color|
      king = find_king(color).first

      rooks = find_piece_type(color, :r)
      rooks.each { |r| fen += r.castle_fen if r.castle_status(king) }
    end

    fen == "" ? "-" : fen
  end

  def check_for_castle(rook_pos, king_pos)
    y, rx = rook_pos
    kx = king_pos[1]
    if rx > kx
      x = kx
      far_x = rx
    else
      x = rx
      far_x = kx
    end
    incr = x + 1
    until incr == far_x
      pos = [incr, y]
      square = self[pos]
      blockers = Piece.all_moves(self[rook_pos].enemy_color)
      if !null_piece?(pos) || blockers.include?(pos)
        return false
      end
      incr += 1
    end
    true
  end

  def in_check?(color)
    king = find_king(color).first
    king_pos = king.position
    is_checked = false
    checked_pieces = []
    collect_checks = Proc.new do |piece|
      if piece.moves.include?(king_pos)
        if (piece.symbol == :p && !piece.invalid_pawn_check?(king_pos)) || piece.symbol != :p
          checked_pieces << piece
          is_checked = true
        end
      else

      end
    end

    Piece.all_moves(king.enemy_color, collect_checks)


    is_checked
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

  def combined_fen(active_color, move_number)
    [
      board_fen,
      active_color,
      castle_fen,
      passant_fen,
      half_clock.to_s,
      move_number
    ].join(" ")
  end

  def board_fen
    fen_str = ""
    space_incr = 0
    board.grid.each do |row|
      row.each do |piece|
        incr_string = space_incr.to_s
        if piece.to_fen == ""
          space_incr += 1
        else
          if space_incr > 0
            fen_str += (incr_string + piece.to_fen)
            space_incr = 0
          else
            fen_str += piece.to_fen if piece.to_fen != " "
          end
        end
      end
      incr_string = space_incr.to_s
      fen_str += incr_string if space_incr > 0
      space_incr = 0
      fen_str += "\/"
    end

    fen_str.chop
  end



  def populate_other_pieces
    side = [[0, :black],[-1, :white]]
      side.each do |side|
        row_idx = side.first
        color = side.last
        grid[row_idx].each_index do |i|
          case i
          when 0
            self[[row_idx, i]] = Rook.new(:r, board, color)
            self[[row_idx, i]].castle = [row_idx, i]
          when 1
            self[[row_idx, i]] = Knight.new(:h, board, color)
          when 2
            self[[row_idx, i]] = Bishop.new(:b, board, color)
          when 3
            self[[row_idx, i]] = Queen.new(:q, board, color)
          when 4
            self[[row_idx, i]] = King.new(:k, board, color)
            self[[row_idx, i]].castle = [row_idx, i]
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
