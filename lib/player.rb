class Player
  attr_reader :color
  def initialize(color)
    @color = color
  end

  def to_fen
    color == :white ? 'w' : 'b'
  end
  
end
