# frozen_string_literal: true

# initialize chess pieces
class Pieces
  attr_accessor :possible_moves, :possible_attack, :white_graveyard,
                :black_graveyard, :white_pieces, :black_pieces, :en_pessante

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

  def our_king_in_check?(teammates, enemies, pos1, pos2)
    all_pos_moves_enemy = []
    teammates[pos2] = teammates.delete(pos1)
    enemies.each do |key, val|
      next if val.name == 'king' || key == pos2

      all_pos_moves_enemy.push(val.possible_attack(key, enemies, teammates, nil, 2).compact)
    end
    teammates[pos1] = teammates.delete(pos2)
    all_pos_moves_enemy.flatten.include?(king_position(teammates))
  end

  def king_position(teammates)
    teammates.key(teammates.values.select { |e| e.name == 'king' }[0])
  end
end

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

# chess piece
class Rook
  attr_reader :name, :unicode
  attr_accessor :moves

  def initialize(color, board)
    @moves = 0
    @board = board
    @color = color
    @name = 'rook'
    @unicode = color == 'black' ? "\e[30m\u265C " : "\u265C "
    @dir = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  end

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = []
    1.upto(7) { |i| @dir.each { |d| moves.push("#{(pos[0].ord + d[0] * i).chr}#{pos[1].to_i + d[1] * i}") } }
    filter_pos_moves(teammates, enemies, depth, moves, pos)
  end

  def filter_pos_moves(teammates, enemies, depth, moves, pos)
    moves.map! { |move| move if @board.labels.include?(move) && teammates[move].nil? && enemies[move].nil? }
    moves = moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }.compact
    return moves unless depth == 1

    moves.reject { |m| @board.pieces.our_king_in_check?(teammates, enemies, pos, m) }
  end

  def possible_attack(pos, teammates, enemies, _ = nil, depth = 1)
    possible_attack = [nil, nil, nil, nil]
    28.times do |i|
      index = i % 4
      forward = "#{(pos[0].ord + @dir[index][0] * ((i + 4) / 4)).chr}#{pos[1].to_i + @dir[index][1] * ((i + 4) / 4)}"
      possible_attack[index] = forward if !enemies[forward].nil? && possible_attack[index].nil?
      possible_attack[index] = 'teammate' if !teammates[forward].nil? && possible_attack[index].nil?
    end
    filter_pos_attack(pos, teammates, enemies, depth, possible_attack)
  end

  def filter_pos_attack(pos, teammates, enemies, depth, possible_attack)
    possible_attack.reject!{ |a| a == 'teammate' || a.nil? }
    return possible_attack unless depth == 1

    possible_attack.map! do |m|
      e = enemies[m]
      enemies.delete(m)
      in_check = @board.pieces.our_king_in_check?(teammates, enemies, pos, m)
      enemies[m] = e
      in_check ? nil : m
    end
    possible_attack.nil? ? [] : possible_attack
  end
end

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

# chess piece
class Bishop
  attr_reader :name, :unicode
  attr_accessor :moves

  def initialize(color, board)
    @board = board
    @color = color
    @moves = 0
    @name = 'bishop'
    @unicode = color == 'black' ? "\e[30m\u265D " : "\u265D "
    @dir = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
  end

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    moves = []
    7.times { |i| @dir.each { |d| moves.push("#{(pos[0].ord + d[0] * (i + 1)).chr}#{pos[1].to_i + d[1] * (i + 1)}") } }
    moves.map! { |move| move if @board.labels.include?(move) && teammates[move].nil? && enemies[move].nil? }
    moves.each_with_index { |_, index| moves[index] = nil if index > 3 && moves[index - 4].nil? }
    moves.reject! { |m| @board.pieces.our_king_in_check?(teammates, enemies, pos, m) } if depth == 1
    moves
  end

  def possible_attack(pos, teammates, enemies, _ = nil, depth = 1)
    possible_attack = [nil, nil, nil, nil]
    28.times do |i|
      forward = "#{(pos[0].ord + @dir[i % 4][0] * ((i + 4) / 4)).chr}#{pos[1].to_i + @dir[i % 4][1] * ((i + 4) / 4)}"
      possible_attack[i % 4] = forward if !enemies[forward].nil? && possible_attack[i % 4].nil?
      possible_attack[i % 4] = 'teammate' if !teammates[forward].nil? && possible_attack[i % 4].nil?
    end
    possible_attack.reject!{ |a| a if a == 'teammate'}
    possible_attack.map! do |m|
      next if m.nil?

      e = enemies[m]
      enemies.delete(m)
      in_check = @board.pieces.our_king_in_check?(teammates, enemies, pos, m)
      enemies[m] = e
      in_check ? nil : m
    end if depth == 1
    possible_attack.nil? ? [] : possible_attack
  end
end

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

# chess piece
class King
  attr_reader :name, :unicode, :castle
  attr_accessor :moves

  def initialize(color, board)
    @board = board
    @color = color
    @name = 'king'
    @moves = 0
    @unicode = color == 'black' ? "\e[30m\u265A " : "\u265A "
    @castle = false
  end

  def possible_moves(pos, teammates, enemies, depth = 0)
    depth += 1
    @castle = false
    moves = [[-1, 1], [0, 1], [1, 1], [-1, 0], [1, 0], [-1, -1], [0, -1], [1, -1]]
    moves.map! { |d| "#{(pos[0].ord + d[0]).chr}#{pos[1].to_i + d[1]}" }
    in_watch = depth == 1 ? get_in_watch(teammates, enemies) : []
    moves.select! { |m| @board.labels.include?(m) && teammates[m].nil? && !in_watch.include?(m) }
    if depth == 1
      check_castling(moves, teammates, enemies)
      moves.map! do |move|
        teammates[move] = teammates.delete(pos)
        enemies['aa'] = enemies.delete(move) unless enemies[move].nil?
        in_watch = get_in_watch(teammates, enemies)
        teammates[pos] = teammates.delete(move)
        enemies[move] = enemies.delete('aa') unless enemies['aa'].nil?
        in_watch.include?(move) ? nil : move
      end
    end
    moves
  end

  def possible_attack(pos, teammates, enemies, p_m = nil, _ = 1)
    possible_moves = p_m.nil? ? possible_moves(pos, teammates, enemies, 2) : p_m
    possible_moves.reject { |move| enemies[move].nil? }
  end

  def get_in_watch(teammates, enemies)
    all_pos_moves_enemy = []
    enemies.each do |key, val|
      p_m = val.possible_moves(key, enemies, teammates, 2)
      p_a = val.possible_attack(key, enemies, teammates, p_m, 2)
      all = val.name == 'pawn' ? p_a : p_m + p_a
      all_pos_moves_enemy.push(all.compact)
    end
    all_pos_moves_enemy.flatten.uniq
  end

  def check_castling(moves, team, enemies)
    return unless @moves.zero? && !@board.king_in_check

    col = @color == 'white' ? '1' : '8'
    left = ["b#{col}", "c#{col}", "d#{col}"].select { |l| team.include?(l) }
    right = ["f#{col}", "g#{col}"].select { |r| team.include?(r) }
    l_w = get_in_watch(team, enemies).include?("d#{col}")
    r_w = get_in_watch(team, enemies).include?("f#{col}")
    if left.empty? && team.include?("a#{col}") && team["a#{col}"].name == 'rook' && team["a#{col}"].moves.zero? && !l_w
      moves.push("c#{col}")
      @castle = true
    end
    if right.empty? && team.include?("h#{col}") && team["h#{col}"].name == 'rook' && team["h#{col}"].moves.zero? && !r_w
      moves.push("g#{col}")
      @castle = true
    end
  end
end
