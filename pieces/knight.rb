# chess piece
class Knight
  attr_reader :name, :unicode
  attr_accessor :moves

  def initialize(color, board)
    @board = board
    @color = color
    @moves = 0
    @name = 'knight'
    @unicode = color == 'black' ? "\e[30m\u265E " : "\u265E "
  end

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]
    moves.map! { |dir| "#{(pos[0].ord + dir[0]).chr}#{pos[1].to_i + dir[1]}" }
    moves.select! { |move| move if @board.labels.include?(move) && teammates[move].nil? }
    moves.reject! { |m| @board.pieces.our_king_in_check?(teammates, enemies, pos, m) } if depth == 1
    moves
  end

  def possible_attack(pos, teammates, enemies, p_m = nil, depth = 0)
    possible_moves = p_m.nil? ? possible_moves(pos, teammates, enemies, depth) : p_m
    enemies.keys.intersection(possible_moves)
  end
end
