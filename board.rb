# frozen_string_literal: true

require_relative 'pieces'

class Board
  attr_accessor :pieces
  attr_reader :labels, :king_in_check
  attr_writer :input, :turn

  def initialize
    @input = nil
    @king_in_check = nil
    @grid = ('a'..'h').to_a.product(('1'..'8').to_a).map(&:join).sort_by{|s| s[1]}.each_slice(8).to_a
    @reverse = @grid.flatten
    @labels = @grid.reverse.flatten
    @pieces = Pieces.new(self)
    @c_option = 0
    @color_options = [["\u001b[48;5;130m", "\u001b[48;5;173m", "\u001b[48;5;136m", "\u001b[48;5;180m"]]
    @turn = 'white'
    display(false, nil)
  end

  def display(in_check, in_check_pos)
    #system 'clear'
    @king_in_check = in_check
    display_upper_graveyard
    display_board(in_check, in_check_pos)
    display_bottom_graveyard
  end

  def display_upper_graveyard
    print "\n  "
    length = @pieces.white_graveyard.length
    length.times { |i| print "#{@color_options[@c_option][0]}#{@pieces.white_graveyard[i]}\e[0m" if i > 7 }
    if @pieces.black_graveyard.length > 8
      length = length >= 8 ? length - 8 : 0
      (27 - (length * 2)).times { |_| print ' ' }
      @pieces.black_graveyard.each_with_index do |p, i|
        print "#{@color_options[@c_option][1]}#{p}\e[0m" if i > 7
      end
    end
    print "\n  "
    @pieces.white_graveyard.each_with_index{ |p, i| print "#{@color_options[@c_option][0]}#{p}\e[0m" if i <= 7 }
    spacing = 27 - (@pieces.white_graveyard.length % 8) * 2
    spacing = 11 if @pieces.white_graveyard.length >= 8
    spacing.times { |i| print ' ' }
    @pieces.black_graveyard.each_with_index do |p, i|
      print "#{@color_options[@c_option][1]}#{p}\e[0m" if i <= 7
    end
    print "\n\n"
  end

  def display_board(in_check, in_check_pos)
    @labels.each.with_index(1) do |label, index|
      print "#{8 - (index/8)} " if index % 8 == 1
      print "#{get_square_color(label, in_check, in_check_pos)}#{get_whats_on_square(label)}\e[0m"
      if (index % 8).zero?
        print"         #{index / 8} "
        8.times do |i|
          label_rev = @reverse[index - (8 - i)]
          print "#{get_square_color(label_rev, in_check, in_check_pos)}#{get_whats_on_square(label_rev)}\e[0m"
        end
        puts ''
      end
    end
    puts '  a b c d e f g h            a b c d e f g h'
  end

  def display_bottom_graveyard
    print "\n  "
    length = 2
    newline = false
    @pieces.black_graveyard.each_with_index do |p, i|
      break if i == 8

      print "#{@color_options[@c_option][1]}#{p}\e[0m"
      length += 2
      if i == 7
        newline = true
        (29 - length).times { |_| print ' '}
        @pieces.white_graveyard.each_with_index do |pi, ind|
          print "#{@color_options[@c_option][0]}#{pi}\e[0m" if ind <= 7
        end
      elsif @pieces.black_graveyard.length - 1 == i
        newline = true
        (27 - (@pieces.black_graveyard.length % 8) * 2).times { |_| print ' ' }
        @pieces.white_graveyard.each_with_index do |pi, ind|
          print "#{@color_options[@c_option][0]}#{pi}\e[0m" if ind <= 7
        end
      end
    end
    print "\n  "
    @pieces.black_graveyard.each_with_index do |p, i|
      next if i < 8

      print "#{@color_options[@c_option][1]}#{p}\e[0m"
    end
    spacing = 27 - (@pieces.black_graveyard.length % 8) * 2
    spacing = 27 if @pieces.black_graveyard.length <= 8
    spacing.times { |_| print ' '} if newline
    (29 - length).times { |_| print ' '} unless newline
    @pieces.white_graveyard.each_with_index do |pi, ind|
      next if ind <= 7 && newline

      print "#{@color_options[@c_option][0]}#{pi}\e[0m"
    end

    print "\n\n"
  end

  def get_square_color(label, in_check, in_check_pos)
    return @color_options[@c_option][2] if label == @input && label[0].ord.even? == label[1].to_i.even? # blue
    return @color_options[@c_option][3] if label == @input && label[0].ord.even? != label[1].to_i.even? # cyan
    return "\u001b[48;5;160m" if !@pieces.possible_attack.nil? && @pieces.possible_attack.include?(label) # red
    return "\u001b[48;5;160m" if in_check && label == in_check_pos # red
    return @color_options[@c_option][0] if label[0].ord.even? == label[1].to_i.even? # dark square

    @color_options[@c_option][1] # light square
  end

  def get_whats_on_square(label)
    if @pieces.possible_moves.include?(label) && !@pieces.possible_attack.nil? && !@pieces.possible_attack.include?(label)
      @turn == 'white' ? "\u001b[38;5;255m\u232C " : "\u001b[38;5;232m\u232C "
    elsif !@pieces.white_pieces[label].nil?
      @pieces.white_pieces[label].unicode
    elsif !@pieces.black_pieces[label].nil?
      @pieces.black_pieces[label].unicode
    else
      '  '
    end
  end
end
