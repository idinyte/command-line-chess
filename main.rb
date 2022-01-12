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
    play_premade
   # play
  end

  def play_premade
    premade = [['f2', 'f3'], ['e7', 'e6'], ['d2', 'd3'], ['d8', 'h4']]
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
      @turn = @turn == 'white' ? 'black' : 'white'
      @board.turn = @turn
    end
    play
  end

  def play
    until @game_over
      puts "#{@turn}\'s turn"
      @pieces = @board.pieces.white_pieces
      @enemy = @board.pieces.black_pieces
      @pieces, @enemy = @enemy, @pieces if @turn == 'black'
      get_input_1_and_2
      attack if @board.pieces.possible_attack.include?(@input_2)
      move
      reset_colors
      enemy_in_check?
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
      puts "#{@turn} player, please select your piece"
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
    while @pieces[second_input].nil?
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
    pawn_stuff if @pieces[@input_2].name == 'pawn'
  end

  def pawn_stuff
    @pieces[@input_2].moves += 1
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
      puts @pieces
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
end

game = Game.new