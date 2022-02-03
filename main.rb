# frozen_string_literal: true

require_relative 'pieces'
require_relative 'board'

require 'json'

# play chess
class Game
  attr_accessor :turn, :board, :king_in_check, :king_in_check_position
  attr_reader :game

  def initialize
    @game_over = false
    @turn = 'white'
    @board = Board.new
    @restart = false
    @input1 = nil
    @input2 = nil
    @king_in_check = false
    @king_in_check_position = nil
    @history = (1..10).to_a
    @copy = []
    #play_premade
    play
  end

  #for testing purposes
  def play_premade
    premade = [["h2", "h4"], ["e7", "e6"], ["h1", "h3"], ["d8", "h4"], ["e2", "e4"], ["h4", "e4"], ["d1", "e2"], ["b8", "c6"], ["g1", "f3"], ["c6", "d4"], ["g2", "g3"], ["a7", "a6"], ["f1", "g2"], ["e4", "f3"], ["a2", "a3"], ["f3", "g3"], ["b2", "b3"], ["g3", "h3"], ["c2", "c3"], ["h3", "c3"], ["a1", "a2"], ["c3", "b3"], ["d2", "d3"], ["b3", "a3"], ["b1", "c3"], ["a3", "c3"], ["c1", "d2"], ["h7", "h5"], ["g2", "f3"], ["h5", "h4"], ["f3", "g2"], ["h4", "h3"], ["g2", "f3"], ["h3", "h2"], ["f3", "g2"], ["h2", "h1"], ["e2", "f1"], ["h1", "f1"]]

    premade.each do |i1, i2|
      puts "#{@turn}\'s turn"
      @team = @board.pieces.white_pieces
      @enemy = @board.pieces.black_pieces
      @team, @enemy = @enemy, @team if @turn == 'black'
      @input1 = i1
      @board.input = @input1
      show_guidlines
      @input2 = i2
      @board.input = i2
      move
      #@board.reset_colors(@king_in_check, @king_in_check_position, @team[@input2].name)
      enemy_in_check?
      game_over?
      @turn = @turn == 'white' ? 'black' : 'white'
      @board.turn = @turn
    end
  end

  def play
    until @game_over
      puts "#{@turn.capitalize}\'s turn"
      teammates_enemies
      get_inputs
      move
      #@board.reset_colors(@king_in_check, @king_in_check_position, @team[@input2].name)
      enemy_in_check?
      game_over?
      @turn = @turn == 'white' ? 'black' : 'white'
      @board.turn = @turn
    end
  end

  def get_inputs(get_input1: true)
    input1 if get_input1
    show_guidlines
    input2
  end

  def input1
    input = gets.chomp
    action(input) if %w[exit draw save load].include?(input)
    while @team[input].nil?
      action(input) if %w[exit draw save load].include?(input)
      puts warning_message(input)
      input = gets.chomp
    end
    @board.input = input
    @input1 = input
  end

  def input2
    second_input = gets.chomp
    action(second_input) if %w[exit draw save load].include?(second_input)
    while @team[second_input].nil?
      action(second_input) if %w[exit draw save load].include?(second_input)
      break if @board.pieces.possible_moves.include?(second_input)

      puts warning_message(second_input)
      second_input = gets.chomp
    end
    manage_inputs(second_input)
  end

  def warning_message(input)
    case input
    when 'load' && !File.size('save.dat').zero?
      'game loaded!'
    when 'save'
      'game saved!'
    else
      'wrong input'
    end
  end

  def manage_inputs(second_input)
    @board.input = second_input
    @input2 = second_input
    return if @team[second_input].nil?

    @input1 = second_input
    get_inputs(get_input1: false)
  end

  def action(second_input)
    case second_input
    when 'exit'
      exit
    when 'save'
      save_game
    when 'load'
      load_game
      teammates_enemies
      @board.display(@king_in_check, @king_in_check_pos)
    when 'draw'
      offer_draw
    end
  end

  def show_guidlines
    update_possible_moves(@input1)
    @board.display(@king_in_check, @king_in_check_position)
  end

  def update_possible_moves(input)
    possible_moves = @team[input].possible_moves(input, @team, @enemy)
    @board.pieces.possible_attack = @team[input].possible_attack(input, @team, @enemy, possible_moves)
    @board.pieces.possible_moves = possible_moves | @board.pieces.possible_attack
  end

  def teammates_enemies
    @team = @board.pieces.white_pieces
    @enemy = @board.pieces.black_pieces
    @team, @enemy = @enemy, @team if @turn == 'black'
  end

  def move
    attack if @board.pieces.possible_attack.include?(@input2)
    @team[@input2] = @team.delete(@input1)
    @team[@input2].moves += 1
    update_history
    pawn_promotion
    castle
  end

  def update_history
    @history.push([@input1, @input2])
    @copy.push([@input1, @input2])
    @history = @history.drop(1)
  end

  def pawn_promotion
    return unless @team[@input2].name == 'pawn' && (@input2[1] == '8' || @input2[1] == '1')

    puts 'Choose: [1] - Queen, [2] - Rook,  [3] - Bishop, [4] - Knight'
    input = gets.chomp
    until %w[1 2 3 4 [1] [2] [3] [4]].include?(input)
      puts 'Choose a number between 1 and 4'
      input = gets.chomp
    end
    promote_pawn(input)
  end

  def promote_pawn(input)
    @team[@input2] = case input
                     when '1'
                       Queen.new(@turn, @board)
                     when '2'
                       Rook.new(@turn, @board)
                     when '3'
                       Bishop.new(@turn, @board)
                     when '4'
                       Knight.new(@turn, @board)
                     end
  end

  def castle
    return unless @team[@input2].name == 'king' && @team[@input2].castle

    col = @turn == 'white' ? '1' : '8'
    case @input2
    when "g#{col}"
      @team["f#{col}"] = @team.delete("h#{col}")
    when "c#{col}"
      @team["d#{col}"] = @team.delete("a#{col}")
    end
  end

  def attack
    graveyard = @turn == 'white' ? @board.pieces.black_graveyard : @board.pieces.white_graveyard
    @board.pieces.possible_moves.push(@input2)
    enemy_pos = @enemy[@input2].nil? ? @board.pieces.en_pessante[1] : @input2
    graveyard.push(@enemy.delete(enemy_pos).unicode)
  end

  def enemy_in_check?
    @board.pieces.possible_moves = @team[@input2].possible_attack(@input2, @team, @enemy, nil, 2)
    enemy_king_position = @enemy.key(@enemy.values.select { |e| e.name == 'king' }[0])
    @king_in_check = @team[@input2].possible_attack(@input2, @team, @enemy, nil, 2).include?(enemy_king_position)
    @king_in_check_position = @king_in_check ? enemy_king_position : nil
    @board.reset_colors(@king_in_check, @king_in_check_position, @team[@input2].name)
  end

  def game_over?
    three_fold_repetition
    all_pos_moves_enemy = []
    @enemy.clone.each do |key, val|
      p_m = val.possible_moves(key, @enemy, @team)
      all_pos_moves_enemy.push(p_m + val.possible_attack(key, @enemy, @team, p_m))
    end
    return unless all_pos_moves_enemy.flatten.compact.empty?

    @game_over = true
    puts "#{@turn.capitalize} wins" if @king_in_check
    puts "It's a draw" unless @king_in_check
  end

  def three_fold_repetition
    return unless @history.count(@history[0]) == 3 && @history.count(@history[1]) == 3

    @game_over = true
    puts "It's a draw"
  end

  def offer_draw
    opponent = @turn == 'white' ? 'black' : 'white'
    puts "#{@turn.capitalize} player has offered a draw. Do you #{opponent} player accept? yes/no"
    input = gets.chomp
    if %w[yes y].include?(input.downcase)
      @game_over = true
      puts "It's a draw"
    end
    exit if @game_over

    puts "#{opponent.capitalize} player has declined to draw."
  end

  def save_game
    save_file = File.open('save.dat', 'w')
    save_file.write(Marshal.dump(self))
    save_file.close
  end

  def load_game
    return if File.size('save.dat').zero?

    game_object = Marshal.load(File.read('save.dat'))
    @board = game_object.board
    @turn = game_object.turn
    @king_in_check = game_object.king_in_check
    @king_in_check_position = game_object.king_in_check_position
  end
end

Game.new
