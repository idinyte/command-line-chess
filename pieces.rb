# frozen_string_literal: true

# initialize chess pieces
class Pieces
  attr_reader :white_pieces, :black_pieces
  attr_accessor :possible_moves, :possible_attack, :white_graveyard, :black_graveyard, :en_pessante

  def initialize(board)
    @board = board
    @possible_moves = []
    @possible_attack = []
    @all_pos_moves_white = []
    @all_pos_moves_black = []
    @white_graveyard = []
    @black_graveyard = []
    @en_pessante = ['', '']
    @white_pieces = get_white(board)
    @black_pieces = get_black(board)
    @white_pieces = white = { 'e1' => King.new('white', board), 'e8' => Queen.new('white', board) }

    @black_pieces = {'f2' => Queen.new('black', board), 'e8' => King.new('black', board), 'e3' => Pawn.new('black', board) }
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

  def king_still_in_check?(teammates, enemies, pos1, pos2)
    all_pos_moves_enemy = []
    teammates[pos2] = teammates.delete(pos1)
    enemies.each { |key, val| all_pos_moves_enemy.push(val.possible_attack(key, enemies, teammates).compact) if val.name != 'king'}
    teammates[pos1] = teammates.delete(pos2)
    all_pos_moves_enemy.flatten.include?(teammates.key(teammates.values.select { |e| e.name == 'king' }[0]))
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

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = []
    all_pieces = teammates.keys + enemies.keys
    2.times { |i| moves.push("#{pos[0]}#{pos[1].to_i + @direction * (i + 1)}") }
    moves.pop if all_pieces.include?(moves[1])
    moves = [nil] if all_pieces.include?(moves[0])
    moves.map! do |m| 
      @board.pieces.king_still_in_check?(teammates, enemies, pos, m) ? nil : m
    end if depth == 1 && @board.king_in_check

    return [moves[0]] if !moves.nil? && @moves.positive?

    moves.nil? ? [] : moves
  end

  def possible_attack(pos, teammates, enemies, p_m = nil)
    [[1, @direction], [-1, @direction]].map do |d| 
      label = "#{(pos[0].ord + d[0]).chr}#{pos[1].to_i + d[1]}"
      enemies.include?(label) || label == @board.pieces.en_pessante[0] ? label : nil
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

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = []
    7.times { |i| @dir.each { |d| moves.push("#{(pos[0].ord + d[0] * (i + 1)).chr}#{pos[1].to_i + d[1] * (i + 1)}") } }
    moves.map! { |move| move if @board.labels.include?(move) && teammates[move].nil? && enemies[move].nil? }
    moves = moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }
    moves.map! do |m|
      @board.pieces.king_still_in_check?(teammates, enemies, pos, m) ? nil : m
    end if depth == 1
    moves
  end

  def possible_attack(pos, teammates, enemies, p_m = nil)
    possible_moves = p_m.nil? ? possible_moves(pos, teammates, enemies, depth) : p_m
    possible_attack = [nil, nil, nil, nil]
    possible_moves.each_with_index do |move, index|
      next if move.nil?

      forward = "#{(move[0].ord + @dir[index % 4][0]).chr}#{move[1].to_i + @dir[index % 4][1]}"
      possible_attack[index % 4] = forward if possible_moves[index + 4].nil? && !enemies[forward].nil?
    end
    possible_attack = possible_attack.each_with_index.map do |move, i|
      forward = "#{(pos[0].ord + @dir[i][0]).chr}#{pos[1].to_i + @dir[i][1]}"
      move.nil? && !enemies[forward].nil? ? forward : move
    end
    possible_attack.nil? ? [] : possible_attack
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

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]
    moves.map! { |dir| "#{(pos[0].ord + dir[0]).chr}#{pos[1].to_i + dir[1]}" }
    moves.map! do |m| 
      @board.pieces.king_still_in_check?(teammates, enemies, pos, m) ? nil : m
    end if depth == 1 && @board.king_in_check
    moves.map { |move| move if @board.labels.include?(move) && teammates[move].nil? }.compact
  end

  def possible_attack(pos, teammates, enemies, p_m = nil)
    possible_moves = p_m.nil? ? possible_moves(pos, teammates, enemies, depth) : p_m
    enemies.keys.intersection(possible_moves)
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

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = []
    7.times { |i| @dir.each { |d| moves.push("#{(pos[0].ord + d[0] * (i + 1)).chr}#{pos[1].to_i + d[1] * (i + 1)}") } }
    moves.map! { |move| move if @board.labels.include?(move) && teammates[move].nil? && enemies[move].nil? }
    moves.map! do |m| 
      @board.pieces.king_still_in_check?(teammates, enemies, pos, m) ? nil : m
    end if depth == 1 && @board.king_in_check
    moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }
    moves
  end

  def possible_attack(pos, teammates, enemies, p_m = nil)
    possible_moves = p_m.nil? ? possible_moves(pos, teammates, enemies, depth) : p_m
    possible_attack = [nil, nil, nil, nil]
    possible_moves.each_with_index do |move, index|
      next if move.nil?

      forward = "#{(move[0].ord + @dir[index % 4][0]).chr}#{move[1].to_i + @dir[index % 4][1]}"
      possible_attack[index % 4] = forward if possible_moves[index + 4].nil? && !enemies[forward].nil?
    end
    possible_attack.each_with_index.map do |move, i|
      forward = "#{(pos[0].ord + @dir[i][0]).chr}#{pos[1].to_i + @dir[i][1]}"
      move.nil? && !enemies[forward].nil? ? forward : move
    end
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

  def possible_moves(pos, teammates, enemies, depth = 0)
    @bishop_dummy.possible_moves(pos, teammates, enemies, depth) + @rook_dummy.possible_moves(pos, teammates, enemies, depth)
  end

  def possible_attack(pos, teammates, enemies, p_m = nil, depth = 1)
    possible_moves = p_m.nil? ? possible_moves(pos, teammates, enemies, depth).each_slice(28).to_a : p_m.each_slice(28).to_a
    @board.pieces.possible_moves = possible_moves[0]
    possible_attack = @bishop_dummy.possible_attack(pos, teammates, enemies, possible_moves[0])
    @board.pieces.possible_moves = possible_moves[1]
    possible_attack += @rook_dummy.possible_attack(pos, teammates, enemies, possible_moves[1])
    @board.pieces.possible_moves = possible_moves.flatten
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

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = [[-1, 1], [0, 1], [1, 1], [-1, 0], [1, 0], [-1, -1], [0, -1], [1, -1]]
    moves.map! { |d| "#{(pos[0].ord + d[0]).chr}#{pos[1].to_i + d[1]}"}
    in_watch = depth == 1 ? get_in_watch(pos, teammates, enemies) : []
    moves = moves.select { |move| @board.labels.include?(move) && teammates[move].nil? && !in_watch.include?(move) }.compact
    moves.map! do |move| 
      teammates[move] = teammates.delete(pos)
      in_watch = get_in_watch(move, teammates, enemies)
      teammates[pos] = teammates.delete(move)
      in_watch.include?(move) ? nil : move
    end if depth == 1
    moves
  end

  def possible_attack(pos, teammates, enemies, p_m = nil)
    possible_moves = p_m.nil? ? possible_moves(pos, teammates, enemies, 2) : p_m
    possible_moves.reject { |move| enemies[move].nil? }
  end

  def get_in_watch(_, teammates, enemies)
    all_pos_moves_enemy = []
    enemies.each do |key, val|
      p_m = val.possible_moves(key, enemies, teammates, 2)
      p_a = val.possible_attack(key, enemies, teammates, p_m)
      all = val.name == 'pawn' ? p_a : p_m + p_a
      all_pos_moves_enemy.push(all.compact)
    end
    all_pos_moves_enemy.flatten.uniq
  end
end