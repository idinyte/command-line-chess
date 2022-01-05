# frozen_string_literal: true

# initialize chess pieces
class Pieces
  attr_reader :white_pieces, :black_pieces
  attr_accessor :possible_moves, :red

  def initialize
    @possible_moves = []
    @red = [] # pieces that can be attacked
    @white_pieces = {'a1' => Rook.new('white'), 'b1' => Knight.new('white'), 'c1' => Bishop.new('white'), 'd1' => Queen.new('white'), 
                     'e1' => King.new('white'), 'f1' => Bishop.new('white'), 'g1' => Knight.new('white'), 'h1' => Rook.new('white') }
    @black_pieces = {'a8' => Rook.new('black'), 'b8' => Knight.new('black'), 'c8' => Bishop.new('black'), 'd8' => Queen.new('black'),
                     'e8' => King.new('black'), 'f8' => Bishop.new('black'), 'g8' => Knight.new('black'), 'h8' => Rook.new('black')}
    ('a'..'h').each do |i|
      @white_pieces["#{i}2"] = Pawn.new('white')
      @black_pieces["#{i}7"] = Pawn.new('black')
    end
  end
end

# chess piece
class Pawn
  attr_reader :name, :unicode
  attr_writer :moves

  def initialize(color)
    @moves = 0
    @is_alive = true
    @name = 'pawn'
    @color = color
    @unicode = color == 'black' ? "\e[30m\u265F " : "\u265F "
  end

  def possible_moves(position, board)
    moves = []
    direction = @color == 'black' ? -1 : 1
    2.times { |i| moves.push("#{position[0]}#{position[1].to_i + direction*(i+1)}") }
    moves = [] if board.pieces.white_pieces.include?(moves[0]) || board.pieces.black_pieces.include?(moves[0])
    moves.pop if board.pieces.white_pieces.include?(moves[1]) || board.pieces.black_pieces.include?(moves[1])
    moves = moves[0] if moves.length == 2 && @moves.positive?
    moves
  end

  def red_squares(position)
    red = nil
  end
end

# chess piece
class Rook
  attr_reader :name, :unicode

  def initialize(color)
    @color = color
    @is_alive = true
    @name = 'rook'
    @unicode = color == 'black' ? "\e[30m\u265C " : "\u265C "
  end

  def possible_moves(pos, board)
    moves = []
    dir = [[0, 1], [0, -1], [-1, 0], [1, 0]]
    teammates = @color == 'white' ? board.pieces.white_pieces : board.pieces.black_pieces
    enemies = @color == 'white' ? board.pieces.black_pieces : board.pieces.white_pieces
    7.times { |i| dir.each { |d| moves.push("#{(pos[0].ord + d[0] * (i + 1)).chr}#{pos[1].to_i + d[1] * (i + 1)}") } }
    moves = moves.map do |move| 
      if board.labels.include?(move) && teammates[move].nil? && enemies[move].nil?
        move
      else
        nil
      end
    end
    moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }
    moves
  end

  def red_squares(position)
    red = nil
  end
end

# chess piece
class Knight
  attr_reader :name, :unicode

  def initialize(color)
    @color = color
    @is_alive = true
    @name = 'knight'
    @unicode = color == 'black' ? "\e[30m\u265E " : "\u265E "
  end

  def possible_moves(position, board)
    moves = []
    directions = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]
    teammates = @color == 'white' ? board.pieces.white_pieces : board.pieces.black_pieces
    directions.each { |dir| moves.push("#{(position[0].ord + dir[0]).chr}#{position[1].to_i + dir[1]}") }
    moves = moves.map do |move| 
      if board.labels.include?(move) && teammates[move].nil?
        move
      else
        nil
      end
    end.compact
    moves
  end

  def red_squares(position)
    red = nil
  end
end

# chess piece
class Bishop
  attr_reader :name, :unicode

  def initialize(color)
    @color = color
    @is_alive = true
    @name = 'bishop'
    @unicode = color == 'black' ? "\e[30m\u265D " : "\u265D "
  end

  def possible_moves(pos, board)
    moves = []
    dir = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    teammates = @color == 'white' ? board.pieces.white_pieces : board.pieces.black_pieces
    enemies = @color == 'white' ? board.pieces.black_pieces : board.pieces.white_pieces
    7.times { |i| dir.each { |d| moves.push("#{(pos[0].ord + d[0] * (i + 1)).chr}#{pos[1].to_i + d[1] * (i + 1)}") } }
    moves = moves.map do |move| 
      if board.labels.include?(move) && teammates[move].nil? && enemies[move].nil?
        move
      else
        nil
      end
    end
    moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }
    moves
  end

  def red_squares(position)
    red = nil
  end
end

# chess piece
class Queen
  attr_reader :name, :unicode
  attr_writer :board

  def initialize(color)
    @color = color
    @is_alive = true
    @name = 'queen'
    @unicode = color == 'black' ? "\e[30m\u265B " : "\u265B "
    @bishop_dummy = Bishop.new(@color)
    @rook_dummy = Rook.new(@color)
  end

  def possible_moves(pos, board)
    @bishop_dummy.possible_moves(pos, board) + @rook_dummy.possible_moves(pos, board)
  end

  def red_squares(position)
    red = nil
  end
end

# chess piece
class King
  attr_reader :name, :unicode

  def initialize(color)
    @color = color
    @is_alive = true
    @name = 'king'
    @unicode = color == 'black' ? "\e[30m\u265A " : "\u265A "
  end

  def possible_moves(pos, board)
    moves = [[-1, 1], [0, 1], [1, 1], [-1, 0], [1, 0], [-1, -1], [0, -1], [1, -1]]
    teammates = @color == 'white' ? board.pieces.white_pieces : board.pieces.black_pieces
    moves.map! { |d| "#{(pos[0].ord + d[0]).chr}#{pos[1].to_i + d[1]}"}
    moves.select { |move| board.labels.include?(move) && teammates[move].nil? }.compact
  end

  def red_squares(position)
    red = nil
  end
end