# chess piece
class Pawn
  attr_reader :name, :unicode
  attr_accessor :moves

  def initialize(color, board)
    @board = board
    @moves = 0
    @name = 'pawn'
    @color = color
    @direction = @color == 'black' ? -1 : 1
    @unicode = color == 'black' ? "\e[30m\u265F " : "\u265F "
  end

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = []
    2.times { |i| moves.push("#{pos[0]}#{pos[1].to_i + @direction * (i + 1)}") }
    moves = filter_pos_moves(moves, depth, teammates, enemies, pos)
    return [moves[0]] if !moves.nil? && @moves.positive?

    moves.nil? ? [] : moves
  end

  def filter_pos_moves(moves, depth, teammates, enemies, pos)
    all_pieces = teammates.keys + enemies.keys
    moves.pop if all_pieces.include?(moves[1])
    moves = [nil] if all_pieces.include?(moves[0])
    moves.reject! { |m| @board.pieces.our_king_in_check?(teammates, enemies, pos, m) } if depth == 1
    moves
  end

  def possible_attack(pos, _, enemies, _ = nil, _ = 0)
    [[1, @direction], [-1, @direction]].map do |d|
      label = "#{(pos[0].ord + d[0]).chr}#{pos[1].to_i + d[1]}"
      enemies.include?(label) || label == @board.pieces.en_pessante[0] ? label : nil
    end.compact
  end
end
