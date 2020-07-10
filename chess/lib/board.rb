# frozen_string_literal: true

# Implements a Chessboard
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
    spawn_pieces
  end

  def spawn_pieces
    puts Piece::COLORS
    Piece::COLORS.each do |color|
      king_row = (color == :Black ? 0 : Board::SIDE_LENGTH - 1)
      spawn_piece(Rook, [king_row, 0], color)
      spawn_piece(Knight, [king_row, 1], color)
      spawn_piece(Bishop, [king_row, 2], color)
      spawn_piece(Queen, [king_row, 3], color)
      spawn_piece(King, [king_row, 4], color)
      spawn_piece(Bishop, [king_row, 5], color)
      spawn_piece(Knight, [king_row, 6], color)
      spawn_piece(Rook, [king_row, 7], color)
      pawn_row = (color == :Black ? 1 : Board::SIDE_LENGTH - 2)
      (0...Board::SIDE_LENGTH).each { |col| spawn_piece(Pawn, [pawn_row, col], color) }
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

  private

  def spawn_piece(piece, position, color)
    row, col = position
    grid[row][col].replace! piece.new(self, Vector.new(position), color)
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
    occupied? ? @piece.symbol : empty_symbol
  end

  # returns the piece and sets the Tile piece to nil
  def pop!
    pc = @piece
    @piece = nil
    pc
  end

  # replaces the Tile's piece with given piece, returning the replaced piece
  def replace!(piece)
    old_piece = @piece
    @piece.kill! if occupied?
    @piece = piece
    old_piece
  end
end

# empty class definitions
class Piece; end
class King < Piece; end
class Queen < Piece; end
class Rook < Piece; end
class Bishop < Piece; end
class Knight < Piece; end
class Pawn < Piece; end