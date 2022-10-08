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
