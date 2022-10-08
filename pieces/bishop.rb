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
