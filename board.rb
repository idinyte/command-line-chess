# frozen_string_literal: true

require_relative 'pieces'

# visual representation of the chess board
class Board
  attr_accessor :pieces
  attr_reader :labels, :king_in_check
  attr_writer :input, :turn

  def initialize
    @input = nil
    @king_in_check = nil
    @grid = ('a'..'h').to_a.product(('1'..'8').to_a).map(&:join).sort_by { |s| s[1] }.each_slice(8).to_a
    @reverse = @grid.flatten
    @labels = @grid.reverse.flatten
    @pieces = Pieces.new(self)
    @turn = 'white'
    display_introductions
    display(false, nil, clear: false)
  end

  def display_introductions
    system 'clear'
    puts "Game looks best when played in default Ubuntu terminal!

Make a move by selecting a square e.g. e2 and select a valid move e.g. e4
At any point during the game you have available commands:
draw - offer a draw
save - save current game state
load - load last saved game
exit - exit the game
  "
  end

  def display(in_check, in_check_pos, clear: true)
    system 'clear' if clear
    @king_in_check = in_check
    display_upper_graveyard
    display_board1(in_check, in_check_pos)
    display_bottom_graveyard
  end

  def display_upper_graveyard
    print "\n  "
    line_up1
    print "\n  "
    line_up2
    print "\n\n"
  end

  def line_up1
    white = @pieces.white_graveyard.drop(8)
    white.each { |p| print "\u001b[48;5;130m#{p}\e[0m" }
    print ' ' * (27 - (white.length * 2))
    @pieces.black_graveyard.drop(8).each { |p| print "\u001b[48;5;173m#{p}\e[0m" }
  end

  def line_up2
    white = @pieces.white_graveyard.take(8)
    white.each { |p| print "\u001b[48;5;130m#{p}\e[0m" }
    print ' ' * (27 - (white.length * 2))
    @pieces.black_graveyard.take(8).each { |p| print "\u001b[48;5;173m#{p}\e[0m" }
  end

  def display_board1(in_check, in_check_pos)
    @labels.each.with_index(1) do |label, index|
      print "#{8 - (index / 8)} " if index % 8 == 1
      print "#{get_square_color(label, in_check, in_check_pos)}#{get_whats_on_square(label)}\e[0m"
      display_line_of_board2(in_check, in_check_pos, index) if (index % 8).zero?
    end
    puts '  a b c d e f g h            a b c d e f g h'
  end

  def display_line_of_board2(in_check, in_check_pos, index)
    print "         #{index / 8} "
    8.times do |i|
      label_rev = @reverse[index - (8 - i)]
      print "#{get_square_color(label_rev, in_check, in_check_pos)}#{get_whats_on_square(label_rev)}\e[0m"
    end
    puts ''
  end

  def display_bottom_graveyard
    reverse = @pieces.black_graveyard.length > 8 || @pieces.white_graveyard.length > 8
    print "\n  " if reverse
    reverse ? line_bottom2 : line_bottom1
    print "\n  "
    reverse ? line_bottom1 : line_bottom2
    print "\n\n"
  end

  def line_bottom1
    black = @pieces.black_graveyard.drop(8)
    black.each { |p| print "\u001b[48;5;173m#{p}\e[0m" }
    print ' ' * (27 - (black.length * 2))
    @pieces.white_graveyard.drop(8).each { |p| print "\u001b[48;5;130m#{p}\e[0m" }
  end

  def line_bottom2
    black = @pieces.black_graveyard.take(8)
    black.each { |p| print "\u001b[48;5;173m#{p}\e[0m" }
    print ' ' * (27 - (black.length * 2))
    @pieces.white_graveyard.take(8).each { |p| print "\u001b[48;5;130m#{p}\e[0m" }
  end

  def get_square_color(label, in_check, in_check_pos)
    is_dark_square = label[0].ord.even? == label[1].to_i.even?
    if label == @input # if current square that is being draw equal to selected square
      return "\u001b[48;5;136m" if is_dark_square # highlight input dark

      return "\u001b[48;5;180m" # highlight input light
    end
    return "\u001b[48;5;160m" if @pieces.possible_attack.include?(label) || (in_check && label == in_check_pos) # red
    return "\u001b[48;5;130m" if is_dark_square # dark square

    "\u001b[48;5;173m" # light square
  end

  def get_whats_on_square(label)
    white = @pieces.white_pieces[label]
    black = @pieces.black_pieces[label]
    guideline = @turn == 'white' ? "\u001b[38;5;255m\u232C " : "\u001b[38;5;232m\u232C "
    return guideline if (@pieces.possible_moves - @pieces.possible_attack).include?(label)
    return black.unicode unless black.nil?
    return white.unicode unless white.nil?

    '  '
  end

  def reset_colors(in_check, in_check_position, piece_name)
    @input = nil
    @pieces.possible_attack = []
    moves = @pieces.possible_moves
    @pieces.en_pessante = if piece_name == 'pawn' && moves.length == 2 && @input2 == moves[1]
                            @board.pieces.en_pessante = moves
                          else
                            ['', '']
                          end
    @pieces.possible_moves = []
    display(in_check, in_check_position)
  end
end
