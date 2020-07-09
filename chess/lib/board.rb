# frozen_string_literal: true

class Board
  SIDE_LENGTH = 8
  attr_reader :grid

  def initialize
    @grid = Array.new(8) do |row|
      Array.new(8) do |col|
        gray = (row.even? ? col.even? : col.odd?)
        Tile.new(gray)
      end
    end
  end

  def valid_position?(position)
    row, col = position.to_a
    row.between?(0, Board::SIDE_LENGTH - 1) && col.between?(0, Board::SIDE_LENGTH - 1)
  end

  def display
    str = String.new
    @grid.each do |row|
      row.each do |tile|
        str << tile.to_s
      end
      str << "\n"
    end
    puts str
  end
end

# Implements a Chessboard Tile
class Tile
  WHITE_EMPTY_SYMBOL = "\u2610"
  GRAY_EMPTY_SYMBOL = "\u2612"

  def initialize(gray = false)
    @gray = gray
    @piece = nil
  end

  def occupied?
    @piece != nil
  end

  def to_s
    empty_symbol = (@gray ? Tile::GRAY_EMPTY_SYMBOL : Tile::WHITE_EMPTY_SYMBOL)
    occupied? ? @piece.to_s : empty_symbol
  end

  # returns the piece and sets the Tile piece to nil
  def pop!
    pc = @piece
    @piece = nil
    pc
  end

  # replaces the Tile's piece with given piece, returning the replaced piece
  def replace!(piece)
    old_piece = piece
    @piece.kill! if occupied?
    @piece = piece
    old_piece
  end
end