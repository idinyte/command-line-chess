# frozen_string_literal: true

require_relative 'pieces'

class Board
  attr_reader :labels

  def initialize()
    @labels = ('a'..'h').to_a.product(('1'..'8').to_a).map(&:join).sort_by{|s| [s[1], s[0]]}.reverse!
    @pieces = Pieces.new
    display
  end

  def display
    @labels.each.with_index(1) do |label, index|
      print "#{8-(index/8)} " if index % 8 == 1
      if @pieces.white_pieces[label].nil? && @pieces.black_pieces[label].nil?
        print "#{get_color(label)}  \e[0m"
      elsif @pieces.white_pieces[label].nil? == false
        print "#{get_color(label)}#{@pieces.white_pieces[label].unicode}\e[0m"
      else
        print "#{get_color(label)}#{@pieces.black_pieces[label].unicode}\e[0m"
      end
      print "\n" if index % 8 == 0
    end

    puts '  a b c d e f g h'
  end

  def get_color(label)
    return "\e[43m" if label[0].ord.even? == label[1].to_i.even?

    "\e[47m"
  end
end

board = Board.new
