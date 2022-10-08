require_relative 'bishop'
require_relative 'rook'

# chess piece
class Queen
  attr_reader :name, :unicode
  attr_accessor :moves

  def initialize(color, board)
    @board = board
    @color = color
    @moves = 0
    @name = 'queen'
    @unicode = color == 'black' ? "\e[30m\u265B " : "\u265B "
    @bishop_dummy = Bishop.new(@color, board)
    @rook_dummy = Rook.new(@color, board)
  end

  def possible_moves(pos, team, enemies, depth = 0)
    @bishop_dummy.possible_moves(pos, team, enemies, depth) + @rook_dummy.possible_moves(pos, team, enemies, depth)
  end

  def possible_attack(pos, team, enemies, _ = nil, d = 1)
    @bishop_dummy.possible_attack(pos, team, enemies, nil, d) + @rook_dummy.possible_attack(pos, team, enemies, nil, d)
  end
end
