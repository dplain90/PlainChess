require_relative 'piece'
require 'singleton'

class NullPiece < Piece
  include Singleton

  attr_accessor :color, :symbol

  def initialize
    @color = nil
    @symbol = :n
  end

end
