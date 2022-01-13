# frozen_string_literal: true

require_relative 'pieces'
require_relative 'board'
class Game
  attr_reader :game

  def initialize
    @game_over = false
    @turn = 'white'
    @board = Board.new
    @input_1 = nil
    @input_2 = nil
    @king_in_check = false
    @king_in_check_position = nil
    @history = (1..10).to_a
    @copy = []
    # play_premade
    play
  end

  def play_premade
    premade = [["e2", "e4"], ["d7", "d5"], ["d2", "d3"], ["d5", "e4"], ["d3", "e4"], ["f7", "f5"], ["e4", "f5"], ["d8", "d1"], ["e1", "d1"], ["g7", "g6"], ["f5", "g6"], ["c8", "f5"], ["g6", "h7"], ["h8", "h7"], ["c1", "h6"], ["h7", "h6"], ["g1", "f3"], ["f5", "c2"], ["d1", "c1"], ["c2", "b1"], ["a1", "b1"], ["h6", "h2"], ["c1", "d1"], ["h2", "h8"], ["h1", "h8"], ["e8", "d8"], ["h8", "h6"], ["f8", "h6"], ["f1", "a6"], ["d8", "c8"], ["a6", "b7"], ["c8", "d8"], ["b7", "a8"], ["d8", "c8"], ["b1", "c1"], ["h6", "c1"], ["g2", "g4"], ["e7", "e5"], ["g4", "g5"], ["e5", "e4"], ["g5", "g6"], ["e4", "e3"], ["g6", "g7"], ["e3", "e2"], ["d1", "c1"], ["g8", "e7"], ["g7", "g8"], ["e7", "g8"], ["c1", "b1"], ["a7", "a6"], ["f3", "g5"], ["a6", "a5"], ["b1", "a1"], ["a5", "a4"], ["a8", "g2"], ["e2", "e1"]]

    premade.each do |i1, i2|
      puts "#{@turn}\'s turn"
      @pieces = @board.pieces.white_pieces
      @enemy = @board.pieces.black_pieces
      @pieces, @enemy = @enemy, @pieces if @turn == 'black'
      @input_1 = i1
      @board.input = @input_1
      show_guidlines(@input_1)
      @input_2 = i2
      @board.input = i2
      attack if @board.pieces.possible_attack.include?(@input_2)
      move
      reset_colors
      enemy_in_check?
      game_over?
      @turn = @turn == 'white' ? 'black' : 'white'
      @board.turn = @turn
    end
    play
  end

  def play
    until @game_over
      puts "#{@turn.capitalize}\'s turn"
      @pieces = @board.pieces.white_pieces
      @enemy = @board.pieces.black_pieces
      @pieces, @enemy = @enemy, @pieces if @turn == 'black'
      get_input_1_and_2
      attack if @board.pieces.possible_attack.include?(@input_2)
      move
      reset_colors
      enemy_in_check?
      game_over?
      @turn = @turn == 'white' ? 'black' : 'white'
      @board.turn = @turn
    end
  end

  def get_input_1_and_2(get_input = true, input = nil)
    input = get_input() if get_input
    show_guidlines(input)
    get_second_input(input)
  end

  def get_input
    input = gets.chomp
    while @pieces[input].nil?
      exit if input == 'exit'
      draw if input == 'draw'
      puts "#{@turn.capitalize} player, please select your piece"
      input = gets.chomp
    end
    @board.input = input
    @input_1 = input
    input
  end

  def show_guidlines(input)
    update_possible_moves(input)
    @board.display(@king_in_check, @king_in_check_position)
  end

  def update_possible_moves(input)
    t_e = get_teammates_enemies
    @board.pieces.possible_moves = @pieces[input].possible_moves(input, t_e[0], t_e[1])
    @board.pieces.possible_attack = @pieces[input].possible_attack(input, t_e[0], t_e[1], @board.pieces.possible_moves)
    @board.pieces.possible_moves = (@board.pieces.possible_moves + @board.pieces.possible_attack).uniq
  end

  def get_teammates_enemies
    teammates = @turn == 'white' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    enemies = @turn != 'white' ? @board.pieces.white_pieces : @board.pieces.black_pieces
    return teammates, enemies
  end

  def get_second_input(input)
    second_input = gets.chomp
    exit if second_input == 'exit'
    draw if second_input == 'draw'
    while @pieces[second_input].nil?
      exit if second_input == 'exit'
      draw if second_input == 'draw'
      break if @board.pieces.possible_moves.include?(second_input)
      puts "Invalid move"
      second_input = gets.chomp
    end
    @board.input = second_input
    unless @pieces[second_input].nil?
      @input_1 = second_input
      get_input_1_and_2(false, second_input)
    else
      @input_2 = second_input
    end
  end

  def move
    @pieces[@input_2] = @pieces.delete(@input_1)
    @history.push([@input_1, @input_2])
    @copy.push([@input_1, @input_2])
    @history = @history.drop(1)
    @pieces[@input_2].moves += 1 if defined?(@pieces[@input_2].moves)
    pawn_stuff if @pieces[@input_2].name == 'pawn'
    castle if @pieces[@input_2].name == 'king' && @pieces[@input_2].castle
  end

  def pawn_stuff
    if @input_2[1] == '8' || @input_2[1] == '1'
      puts 'Choose: [1] - Queen, [2] - Rook,  [3] - Bishop, [4] - Knight'
      input = gets.chomp
      until ['1', '2', '3', '4'].include?(input)
        puts 'Choose a number between 1 and 4'
        input = gets.chomp
      end
      @pieces[@input_2] = Queen.new(@turn, @board) if input == '1'
      @pieces[@input_2] = Rook.new(@turn, @board) if input == '2'
      @pieces[@input_2] = Bishop.new(@turn, @board) if input == '3'
      @pieces[@input_2] = Knight.new(@turn, @board) if input == '4'
    end
  end

  def castle
    col = @turn == 'white' ? '1' : '8'
    case @input_2
    when "g#{col}"
      @pieces["f#{col}"] = @pieces.delete("h#{col}")
    when "c#{col}"
      @pieces["d#{col}"] = @pieces.delete("a#{col}")
    end
  end

  def attack
    graveyard = @turn == 'white' ? @board.pieces.black_graveyard : @board.pieces.white_graveyard
    @board.pieces.possible_moves.push(@input_2)
    enemy_pos = @enemy[@input_2].nil? ? @board.pieces.en_pessante[1] : @input_2
    graveyard.push(@enemy.delete(enemy_pos).unicode)
  end

  def reset_colors
    @board.input = nil
    @board.pieces.possible_attack = []
    moves = @board.pieces.possible_moves
    @board.pieces.en_pessante = if @pieces[@input_2].name == 'pawn' && moves.length == 2 && @input_2 == moves[1]
                                  @board.pieces.en_pessante = moves
                                else
                                  ['', '']
                                end
    @board.pieces.possible_moves = []
    @board.display(@king_in_check, @king_in_check_position)
  end

  def enemy_in_check?
    t_e = get_teammates_enemies
    @board.pieces.possible_moves = @pieces[@input_2].possible_attack(@input_2, t_e[0], t_e[1], nil, 2)
    enemy_king_position = @enemy.key(@enemy.values.select { |e| e.name == 'king' }[0])
    @king_in_check = @pieces[@input_2].possible_attack(@input_2, t_e[0], t_e[1], nil, 2).include?(enemy_king_position)
    @king_in_check_position = @king_in_check ? enemy_king_position : nil
    reset_colors
  end

  def game_over?
    all_pos_moves_enemy = []
    @enemy.clone.each do |key, val|
      p_m = val.possible_moves(key, @enemy, @pieces)
      p_a = val.possible_attack(key, @enemy, @pieces, p_m)
      all_pos_moves_enemy.push(p_m + p_a)
    end
    if all_pos_moves_enemy.flatten.compact.empty?
      @game_over = true
      puts "#{@turn.capitalize} is a winner" if @king_in_check
      puts "It's a draw" if !@king_in_check
    end
    # three fold repetition
    if @history.count(@history[0]) == 3 && @history.count(@history[1]) == 3
      @game_over = true
      puts "It's a draw"
    end
  end

  def draw
    opponent = @turn == 'white' ? 'black' : 'white'
    puts "#{@turn.capitalize} player has offered a draw. Do you #{opponent} player accept? yes/no"
    input = gets.chomp
    if ['yes', 'y'].include?(input.downcase)
      @game_over = true
      puts "It's a draw"
    end
    exit if @game_over

    puts "#{opponent.capitalize} player has declined to draw."
  end
end

game = Game.new