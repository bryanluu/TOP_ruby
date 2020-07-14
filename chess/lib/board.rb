# frozen_string_literal: true

# Implements a Chessboard
class Board
  SIDE_LENGTH = 8
  ROWS = {}
  COLUMNS = {}
  (1..SIDE_LENGTH).each { |row| ROWS[row] = SIDE_LENGTH - row }
  %i[a b c d e f g h].each_with_index { |col, i| COLUMNS[col] = i }
  SIDE_LENGTH.freeze
  ROWS.freeze
  COLUMNS.freeze

  def initialize
    @grid = Array.new(8) do |row|
      Array.new(8) do |col|
        gray = (row.even? ? col.even? : col.odd?)
        Tile.new(gray)
      end
    end
    spawn_pieces
  end

  def [](*args)
    if args.length == 1
      raise ArgumentError, 'Can only be single-indexed by Vectors' unless args[0].is_a?(Vector) || args[0].is_a?(Array)

      row, col = args[0].to_a
    elsif args.length == 2
      raise ArgumentError, 'Can only be double-indexed by integers between 0-7' unless valid_position?(args)

      row, col = args
    else
      raise ArgumentError, "Too many arguments given! Expected 2, got #{args.length}"
    end
    @grid[row][col]
  end

  def valid_position?(position)
    row, col = position.to_a
    row.between?(0, Board::SIDE_LENGTH - 1) && col.between?(0, Board::SIDE_LENGTH - 1)
  end

  def display
    str = String.new
    @grid.each_with_index do |row, i|
      str << "#{Board::SIDE_LENGTH - i} "
      str << row.map(&:to_s).join(' ')
      str << "\n"
    end
    str << '  '
    str << %i[a b c d e f g h].map(&:to_s).join(' ')
    str << "\n"
    puts str
  end

  def move_piece!(origin, destination)
    return false unless self[origin].occupied?
    return false unless valid_position?(destination) && valid_path?(origin, destination)

    piece = self[origin].pop!
    replaced = self[destination].replace!(piece)
    replaced.nil? ? true : replaced
  end

  def valid_path?(origin, destination)
    piece = self[origin].piece
    return valid_knight_path?(piece, origin, destination) if piece.is_a? Knight
    return valid_pawn_path?(piece, origin, destination) if piece.is_a? Pawn

    valid_general_path?(piece, origin, destination)
  end

  private

  def spawn_pieces
    Piece::COLORS.each do |color|
      spawn_king_row(color)
      spawn_pawns(color)
    end
  end

  def spawn_piece(piece, position, color)
    self[position].replace! piece.new(color)
  end

  def spawn_king_row(color)
    king_row = (color == :Black ? 0 : Board::SIDE_LENGTH - 1)
    spawn_piece(Rook, [king_row, 0], color)
    spawn_piece(Knight, [king_row, 1], color)
    spawn_piece(Bishop, [king_row, 2], color)
    spawn_piece(Queen, [king_row, 3], color)
    spawn_piece(King, [king_row, 4], color)
    spawn_piece(Bishop, [king_row, 5], color)
    spawn_piece(Knight, [king_row, 6], color)
    spawn_piece(Rook, [king_row, 7], color)
  end

  def spawn_pawns(color)
    pawn_row = (color == :Black ? 1 : Board::SIDE_LENGTH - 2)
    (0...Board::SIDE_LENGTH).each { |col| spawn_piece(Pawn, [pawn_row, col], color) }
  end

  def valid_knight_path?(knight, origin, destination)
    movement = destination - origin
    food = self[destination].piece
    knight.valid_move?(movement) && (food ? food.color != piece.color : true)
  end

  def valid_pawn_path?(pawn, origin, destination)
    movement = destination - origin
    food = self[destination].piece
    step = (pawn.white? ? -1 : 1)
    if [[step, 1], [step, -1]].include?(movement)
      food && food.color != pawn.color
    elsif movement == [2 * step, 0]
      !self[origin + Vector.new([step, 0])].occupied? && food.nil?
    else
      movement == [step, 0] && food.nil?
    end
  end

  def valid_general_path?(piece, origin, destination)
    movement = destination - origin
    return false unless piece.valid_move?(movement)

    steps = movement.max
    step = movement / steps
    (1...steps).each do |i|
      pos = origin + step * i
      return false if self[pos].occupied?
    end
    !self[destination].occupied? || self[destination].piece.color != piece.color
  end
end

# Implements a Chessboard Tile
class Tile
  WHITE_EMPTY_SYMBOL = "\u2610"
  GRAY_EMPTY_SYMBOL = "\u2612"

  attr_reader :piece

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
