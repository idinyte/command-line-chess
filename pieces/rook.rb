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
