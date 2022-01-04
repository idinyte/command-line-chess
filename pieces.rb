# frozen_string_literal: true

class Pieces
  attr_reader :white_pieces, :black_pieces

  def initialize
    @white_pieces = {'a1'=> Rook.new('white', 'a1'), 'b1'=> Knight.new('white', 'b1'), 'c1'=> Bishop.new('white', 'c1'),
                     'd1'=> Queen.new('white', 'd1'), 'e1'=> King.new('white', 'e1'), 'f1'=> Bishop.new('white', 'f1'),
                     'g1'=> Knight.new('white', 'g1'), 'h1'=> Rook.new('white', 'h1')}
    @black_pieces = {'a8'=> Rook.new('black', 'a8'), 'b8'=> Knight.new('black', 'b8'), 'c8'=> Bishop.new('black', 'c8'),
                     'd8'=> Queen.new('black', 'd8'), 'e8'=> King.new('black', 'e8'), 'f8'=> Bishop.new('black', 'f8'),
                     'g8'=> Knight.new('black','g8'), 'h8'=> Rook.new('black', 'h8')}
    ('a'..'h').each do |i|
      @white_pieces["#{i}2"] = Pawn.new('white', "#{i}2")
      @black_pieces["#{i}7"] = Pawn.new('black', "#{i}7")
    end
  end
end

class Pawn
  attr_reader :name, :unicode

  @moves = 0
  @is_alive = true
  @name = 'pawn'
  def initialize(color, position)
    @unicode = color == 'black' ? "\e[30m\u265F " : "\u265F "
    @position = position
  end
end

class Rook
  attr_reader :name, :unicode

  @is_alive = true
  @name = 'rook'
  def initialize(color, position)
    @unicode = color == 'black' ? "\e[30m\u265C " : "\u265C "
    @position = position
  end
end

class Knight
  attr_reader :name, :unicode

  @is_alive = true
  @name = 'knight'
  def initialize(color, position)
    @unicode = color == 'black' ? "\e[30m\u265E " : "\u265E "
    @position = position
  end
end

class Bishop
  attr_reader :name, :unicode

  @is_alive = true
  @name = 'bishop'
  def initialize(color, position)
    @unicode = color == 'black' ? "\e[30m\u265D " : "\u265D "
    @position = position
  end
end

class Queen
  attr_reader :name, :unicode

  @is_alive = true
  @name = 'queen'
  def initialize(color, position)
    @unicode = color == 'black' ? "\e[30m\u265B " : "\u265B "
    @position = position
  end
end

class King
  attr_reader :name, :unicode

  @is_alive = true
  @name = 'king'
  def initialize(color, position)
    @unicode = color == 'black' ? "\e[30m\u265A " : "\u265A "
    @position = position
  end
end