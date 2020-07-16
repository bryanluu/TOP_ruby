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
        gray = (row.even? ? col.even? : col.odd?) # every other tile is gray
        Tile.new(gray)
      end
    end
    @graveyard = { White: [], Black: [] }.freeze
    spawn_pieces # spawn Chess pieces
  end

  # indexes into the grid of Tiles using either a vector or row and col
  def [](*args)
    if args.length == 1
      unless (args[0].is_a?(Vector) || args[0].is_a?(Array)) && valid_position?(args[0])
        raise ArgumentError, 'Can only be single-indexed by valid on-board Vectors'
      end

      row, col = args[0].to_a
    elsif args.length == 2
      raise ArgumentError, 'Can only be double-indexed by integers between 0-7' unless valid_position?(args)

      row, col = args
    else
      raise ArgumentError, "Too many arguments given! Expected 2, got #{args.length}"
    end
    @grid[row][col]
  end

  # returns whether the position (Vector) is on the board or not
  def valid_position?(position)
    row, col = position.to_a
    row.between?(0, Board::SIDE_LENGTH - 1) && col.between?(0, Board::SIDE_LENGTH - 1)
  end

  # displays the Chessboard, with row and column names
  def display
    str = String.new
    str << dead_pieces_str(:White)
    @grid.each_with_index do |row, i|
      str << "#{Board::SIDE_LENGTH - i} " # print current row number
      str << row.map(&:to_s).join(' ') # print row of tiles
      str << "\n"
    end
    str << '  '
    str << %i[a b c d e f g h].map(&:to_s).join(' ') # print columns
    str << "\n"
    str << dead_pieces_str(:Black)
    puts str
  end

  # attempts to move the piece at origin to destination,
  # returns false if not possible, otherwise moves the piece and returns true
  def move_piece!(origin, destination)
    origin = Vector.new(origin) unless origin.is_a? Vector
    destination = Vector.new(destination) unless destination.is_a? Vector
    return false unless self[origin].occupied?
    return false unless valid_position?(destination) && valid_path?(origin, destination)

    piece = self[origin].pop!
    piece.move! if piece.is_a? Pawn
    replaced = self[destination].replace!(piece)
    @graveyard[replaced.color] << replaced unless replaced.nil? # add the dead piece to the graveyard
    true
  end

  private

  # spawn Chess pieces at default positions
  def spawn_pieces
    Piece::COLORS.each do |color|
      spawn_king_row(color)
      spawn_pawns(color)
    end
  end

  # spawn given color piece at position
  def spawn_piece(piece, position, color)
    self[position].replace! piece.new(color)
  end

  # spawn pieces on the King row with given color
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

  # spawn pawns with given color
  def spawn_pawns(color)
    pawn_row = (color == :Black ? 1 : Board::SIDE_LENGTH - 2)
    (0...Board::SIDE_LENGTH).each { |col| spawn_piece(Pawn, [pawn_row, col], color) }
  end

  # checks the path from origin to destination if it is valid for the piece at origin
  def valid_path?(origin, destination)
    piece = self[origin].piece
    return false if piece.nil?
    return valid_knight_path?(origin, destination) if piece.is_a? Knight
    return valid_pawn_path?(origin, destination) if piece.is_a? Pawn

    valid_general_path?(origin, destination)
  end

  # checks whether path is valid for knight
  def valid_knight_path?(origin, destination)
    movement = destination - origin
    knight = self[origin].piece
    food = self[destination].piece
    knight.valid_move?(movement) && (food ? food.color != piece.color : true)
  end

  # checks whether path is valid for pawn
  def valid_pawn_path?(origin, destination)
    movement = destination - origin
    pawn = self[origin].piece
    food = self[destination].piece
    step = (pawn.white? ? -1 : 1)
    if [[step, 1], [step, -1]].include?(movement.to_a)
      food && food.color != pawn.color
    elsif movement == [2 * step, 0]
      !self[origin + Vector.new([step, 0])].occupied? && food.nil?
    else
      movement == [step, 0] && food.nil?
    end
  end

  # checks whether path is valid for general piece
  def valid_general_path?(origin, destination)
    movement = destination - origin
    piece = self[origin].piece
    return false unless piece.valid_move?(movement)

    steps = movement.to_a.map(&:abs).max
    step = movement / steps
    (1...steps).each do |i|
      pos = origin + step * i
      return false if self[pos].occupied?
    end
    !self[destination].occupied? || self[destination].piece.color != piece.color
  end

  # returns the dead pieces of the given color as a string if there are dead-pieces, otherwise blank string
  def dead_pieces_str(color)
    @graveyard[color].empty? ? String.new : "#{Piece::TEAM_ICONS[Piece.opposite(color)]}: #{@graveyard[color].map(&:symbol).join}\n"
  end

  # returns whether the piece at location is in danger
  def piece_in_danger?(location)
    !enemies_attacking(location).empty?
  end

  # returns a list of the enemies attacking location
  def enemies_attacking(location)
    location = Vector.new(location) if location.is_a? Array
    color = self[location].piece.color
    # add any enemy knights to the list
    enemies = knight_spots_surrounding(location).filter do |spot|
      valid_position?(spot) && self[spot].piece.is_a?(Knight) && self[spot].piece.color != color
    end
    # add general enemies attacking location
    tree = immediate_spots_surrounding(location)
    tree.filter! { |spot| valid_position?(spot) } # filter out only spots on board
    tree.each do |spot|
      if self[spot].occupied? # if the spot has an enemy piece, add it and continue
        enemies += enemy_on(spot, location)
        next
      end
      # otherwise
      diff = spot - location # the direction of the next spot
      step = diff.to_a.map(&:abs).max # the magnitude of diff
      next_spot = spot + diff / step # take a single-sized step toward the next spot
      tree << next_spot if valid_position?(next_spot) # only add children if on board
    end
    enemies
  end

  # return the 8 immediate surrounding spots around location
  def immediate_spots_surrounding(location)
    step = [-1, 0, 1]
    moves = step.product(step).reject { |move| move == [0, 0] }
    moves.map { |move| location + Vector.new(move) }
  end

  # return the 8 knight-spots around location
  def knight_spots_surrounding(location)
    moves = [1, -1].product([2, -2])
    moves += moves.map(&:reverse)
    moves.map { |move| location + Vector.new(move) }
  end

  # returns the spot occupied by a general (non-Knight) enemy or a Pawn
  def enemy_on(spot, location)
    if self[spot].piece.is_a? Pawn
      return [spot] if valid_pawn_path?(spot, location)
    else
      return [spot] if valid_general_path?(spot, location)
    end
    []
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

  # whether the Tile is occupied
  def occupied?
    @piece != nil
  end

  # shows the empty Tile symbol if empty, otherwise shows the piece symbol
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
