# frozen_string_literal: true

require_relative 'pieces'
require_relative 'board'
class Game

  def initialize
    @game_over = false
    @board = Board.new
    @turn = 'white'
    @input_1 = nil
    @input_2 = nil
    play()
  end

  def play
    until @game_over
      puts "#{@turn}\'s turn"
      @pieces = @turn == 'white' ? @board.pieces.white_pieces : @board.pieces.black_pieces
      get_input_1_and_2
      reset_colors
      move
      @turn = @turn == 'white' ? 'black' : 'white'
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
      puts "#{@turn} player, please select your piece"
      input = gets.chomp
    end
    @board.input = input
    @input_1 = input
    input
  end

  def show_guidlines(input)
    @board.pieces.possible_moves = @pieces[input].possible_moves(input, @board)
    @board.pieces.red = @pieces[input].red_squares(input)
    @board.display
  end

  def get_second_input(input)
    second_input = gets.chomp
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
    @pieces[@input_1].moves = 1 if @pieces[@input_1].name == 'pawn'
    @pieces[@input_2] = @pieces.delete(@input_1)
    @board.display
  end

  def reset_colors
    @board.input = nil
    @board.pieces.possible_moves = []
    @board.pieces.red = []
  end
end

game = Game.new