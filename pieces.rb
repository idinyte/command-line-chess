# frozen_string_literal: true

# initialize chess pieces
class Pieces
  attr_reader :white_pieces, :black_pieces
  attr_accessor :possible_moves, :possible_attack, :white_graveyard, :black_graveyard

  def initialize(board)
    @possible_moves = []
    @possible_attack = []
    @white_graveyard = []
    @black_graveyard = []
    @white_pieces = get_white(board)
    @black_pieces = get_black(board)
  end

  def get_white(board)
    white = { 'a1' => Rook.new('white', board), 'b1' => Knight.new('white', board),
              'c1' => Bishop.new('white', board), 'd1' => Queen.new('white', board),
              'e1' => King.new('white', board), 'f1' => Bishop.new('white', board),
              'g1' => Knight.new('white', board), 'h1' => Rook.new('white', board) }
    ('a'..'h').each { |i| white["#{i}2"] = Pawn.new('white', board) }
    white
  end

  def get_black(board)
    black = { 'a8' => Rook.new('black', board), 'b8' => Knight.new('black', board),
              'c8' => Bishop.new('black', board), 'd8' => Queen.new('black', board),
              'e8' => King.new('black', board), 'f8' => Bishop.new('black', board),
              'g8' => Knight.new('black', board), 'h8' => Rook.new('black', board) }
    ('a'..'h').each { |i| black["#{i}7"] = Pawn.new('black', board) }
    black
  end
end

# chess piece
class Pawn
  attr_reader :name, :unicode
  attr_writer :moves

  def initialize(color, board)
    @board = board
    @moves = 0
    @name = 'pawn'
    @color = color
    @direction = @color == 'black' ? -1 : 1
    @unicode = color == 'black' ? "\e[30m\u265F " : "\u265F "
  end

  def possible_moves(position)
    @enemy = @color == 'black' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    moves = []
    all_pieces = @board.pieces.white_pieces.keys + @board.pieces.black_pieces.keys
    2.times { |i| moves.push("#{position[0]}#{position[1].to_i + @direction * (i + 1)}") }
    moves.pop if all_pieces.include?(moves[1])
    moves = [nil] if all_pieces.include?(moves[0])
    @moves.positive? ? [moves[0]] : moves
  end

  def possible_attack(position)
    [[1, @direction], [-1, @direction]].map do |d| 
      label = "#{(position[0].ord + d[0]).chr}#{position[1].to_i + d[1]}"
      @enemy.include?(label) ? label : nil
    end.compact
  end
end

# chess piece
class Rook
  attr_reader :name, :unicode

  def initialize(color, board)
    @board = board
    @color = color
    @name = 'rook'
    @unicode = color == 'black' ? "\e[30m\u265C " : "\u265C "
    @dir = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  end

  def possible_moves(pos)
    initialize_pieces if @teammates.nil?
    moves = []
    7.times { |i| @dir.each { |d| moves.push("#{(pos[0].ord + d[0] * (i + 1)).chr}#{pos[1].to_i + d[1] * (i + 1)}") } }
    moves.map! { |move| move if @board.labels.include?(move) && @teammates[move].nil? && @enemies[move].nil? }
    moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }
    moves
  end

  def possible_attack(position)
    possible_moves = @board.pieces.possible_moves
    possible_attack = [nil, nil, nil, nil]
    possible_moves.each_with_index do |move, index|
      next if move.nil?

      forward = "#{(move[0].ord + @dir[index % 4][0]).chr}#{move[1].to_i + @dir[index % 4][1]}"
      possible_attack[index % 4] = forward if possible_moves[index + 4].nil? && !@enemies[forward].nil?
    end
    possible_attack.each_with_index.map do |move, i|
      forward = "#{(position[0].ord + @dir[i][0]).chr}#{position[1].to_i + @dir[i][1]}"
      move.nil? && !@enemies[forward].nil? ? forward : move
    end
  end

  def initialize_pieces
    @teammates = @color == 'white' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    @enemies = @color == 'white' ? @board.pieces.black_pieces : @board.pieces.white_pieces
  end
end

# chess piece
class Knight
  attr_reader :name, :unicode

  def initialize(color, board)
    @board = board
    @color = color
    @name = 'knight'
    @unicode = color == 'black' ? "\e[30m\u265E " : "\u265E "
  end

  def possible_moves(position)
    initialize_pieces if @teammates.nil?
    @enemies = @color == 'black' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    directions = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]
    directions.map! { |dir| "#{(position[0].ord + dir[0]).chr}#{position[1].to_i + dir[1]}" }
    directions.map { |move| move if @board.labels.include?(move) && @teammates[move].nil? }.compact
  end

  def possible_attack(_)
    possible_moves = @board.pieces.possible_moves
    @enemies.keys.intersection(possible_moves)
  end

  def initialize_pieces
    @teammates = @color == 'white' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    @enemies = @color == 'black' ? @board.pieces.white_pieces : @board.pieces.black_pieces
  end
end

# chess piece
class Bishop
  attr_reader :name, :unicode

  def initialize(color, board)
    @board = board
    @color = color
    @name = 'bishop'
    @unicode = color == 'black' ? "\e[30m\u265D " : "\u265D "
    @dir = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
  end

  def possible_moves(pos)
    initialize_pieces if @teammates.nil?
    moves = []
    7.times { |i| @dir.each { |d| moves.push("#{(pos[0].ord + d[0] * (i + 1)).chr}#{pos[1].to_i + d[1] * (i + 1)}") } }
    moves = moves.map { |move| move if @board.labels.include?(move) && @teammates[move].nil? && @enemies[move].nil? }
    moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }
    moves
  end

  def possible_attack(position)
    possible_moves = @board.pieces.possible_moves
    possible_attack = [nil, nil, nil, nil]
    possible_moves.each_with_index do |move, index|
      next if move.nil?

      forward = "#{(move[0].ord + @dir[index % 4][0]).chr}#{move[1].to_i + @dir[index % 4][1]}"
      possible_attack[index % 4] = forward if possible_moves[index + 4].nil? && !@enemies[forward].nil?
    end
    possible_attack.each_with_index.map do |move, i|
      forward = "#{(position[0].ord + @dir[i][0]).chr}#{position[1].to_i + @dir[i][1]}"
      move.nil? && !@enemies[forward].nil? ? forward : move
    end
  end

  def initialize_pieces
    @teammates = @color == 'white' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    @enemies = @color == 'white' ? @board.pieces.black_pieces : @board.pieces.white_pieces
  end
end

# chess piece
class Queen
  attr_reader :name, :unicode

  def initialize(color, board)
    @board = board
    @color = color
    @name = 'queen'
    @unicode = color == 'black' ? "\e[30m\u265B " : "\u265B "
    @bishop_dummy = Bishop.new(@color, board)
    @rook_dummy = Rook.new(@color, board)
  end

  def possible_moves(pos)
    @bishop_dummy.possible_moves(pos) + @rook_dummy.possible_moves(pos)
  end

  def possible_attack(position)
    possible_moves = @board.pieces.possible_moves.each_slice(28).to_a
    @board.pieces.possible_moves = possible_moves[0]
    possible_attack = @bishop_dummy.possible_attack(position)
    @board.pieces.possible_moves = possible_moves[1]
    possible_attack += @rook_dummy.possible_attack(position)
    @board.pieces.possible_moves = possible_moves.flatten()
    possible_attack
  end
end

# chess piece
class King
  attr_reader :name, :unicode

  def initialize(color, board)
    @board = board
    @color = color
    @name = 'king'
    @unicode = color == 'black' ? "\e[30m\u265A " : "\u265A "
  end

  def possible_moves(pos)
    moves = [[-1, 1], [0, 1], [1, 1], [-1, 0], [1, 0], [-1, -1], [0, -1], [1, -1]]
    teammates = @color == 'white' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    moves.map! { |d| "#{(pos[0].ord + d[0]).chr}#{pos[1].to_i + d[1]}"}
    moves.select { |move| @board.labels.include?(move) && teammates[move].nil? }.compact
  end

  def possible_attack(position)
    enemies = @color == 'black' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    @board.pieces.possible_moves.reject { |move| enemies[move].nil? }
  end
end