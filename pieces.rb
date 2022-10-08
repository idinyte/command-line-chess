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