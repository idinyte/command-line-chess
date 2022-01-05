# frozen_string_literal: true

require_relative 'pieces'

class Board
  attr_reader :labels, :pieces
  attr_writer :input

  def initialize()
    @input = nil
    @labels = ('a'..'h').to_a.product(('1'..'8').to_a).map(&:join).sort_by{|s| s[1]}.each_slice(8).to_a.reverse.flatten
    @pieces = Pieces.new
    display
  end

  def display
    #system "clear"
    @labels.each.with_index(1) do |label, index|
      print "#{8-(index/8)} " if index % 8 == 1
      print "#{get_square_color(label)}#{get_whats_on_square(label)}\e[0m"
      print "\n" if index % 8 == 0
    end

    puts '  a b c d e f g h'
  end

  def get_square_color(label)
    return "\e[44m" if label == @input && label[0].ord.even? == label[1].to_i.even?
    return "\e[46m" if label == @input && label[0].ord.even? != label[1].to_i.even?
    return "\e[42m" if @pieces.possible_moves.include?(label)
    return "\e[43m" if label[0].ord.even? == label[1].to_i.even?

    "\e[47m"
  end

  def get_whats_on_square(label)
    on_square = '  '
    on_square = @pieces.white_pieces[label].unicode if @pieces.white_pieces[label].nil? == false
    on_square = @pieces.black_pieces[label].unicode if @pieces.black_pieces[label].nil? == false
    on_square
  end
end
