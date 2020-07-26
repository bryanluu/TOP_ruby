# frozen_string_literal: true

# Implements a Chessboard
class Board
  SIDE_LENGTH = 8
  ROW_TO_INDEX = {}
  COLUMN_TO_INDEX = {}
  (1..SIDE_LENGTH).each { |row| ROW_TO_INDEX[row] = SIDE_LENGTH - row }
  %i[a b c d e f g h].each_with_index { |col, i| COLUMN_TO_INDEX[col] = i }
  INDEX_TO_ROW = {}
  INDEX_TO_COLUMN = {}
  (0...SIDE_LENGTH).each { |row| INDEX_TO_ROW[row] = SIDE_LENGTH - row }
  %i[a b c d e f g h].each_with_index { |col, i| INDEX_TO_COLUMN[i] = col }
  SIDE_LENGTH.freeze
  ROW_TO_INDEX.freeze
  COLUMN_TO_INDEX.freeze
  INDEX_TO_ROW.freeze
  INDEX_TO_COLUMN.freeze

  def initialize
    @grid = Array.new(8) do |row|
      Array.new(8) do |col|
        gray = (row.even? ? col.even? : col.odd?) # every other tile is gray
        Tile.new(Board::INDEX_TO_ROW[row], Board::INDEX_TO_COLUMN[col], gray)
      end
    end
    @graveyard = { White: [], Black: [] }.freeze
    spawn_pieces # spawn Chess pieces
    @last_move = nil
  end

  # indexes into the grid of Tiles using either a vector or row and col
  def [](*args)
    if args.length == 1
      location = args[0]
      location = Board.location_vector(location) if location.is_a? String
      unless (location.is_a?(Vector) || location.is_a?(Array)) && Board.valid_position?(location)
        raise ArgumentError, 'Can only be single-indexed by valid on-board Vectors'
      end

      row, col = location.to_a
    elsif args.length == 2
      raise ArgumentError, 'Can only be double-indexed by integers between 0-7' unless Board.valid_position?(args)

      row, col = args
    else
      raise ArgumentError, "Too many arguments given! Expected 2, got #{args.length}"
    end
    @grid[row][col]
  end

  # returns whether the position (Vector) is on the board or not
  def self.valid_position?(position)
    row, col = position.to_a
    return false if row.nil? || col.nil?

    row.between?(0, Board::SIDE_LENGTH - 1) && col.between?(0, Board::SIDE_LENGTH - 1)
  end

  # displays the Chessboard, with row and column names
  def display
    str = String.new
    str << dead_pieces_str(:White)
    str << '  '
    str << Board::COLUMN_TO_INDEX.keys.map(&:to_s).join(' ') # print columns
    str << "\n"
    @grid.each_with_index do |row, i|
      str << "#{Board::SIDE_LENGTH - i} " # print current row number
      str << row.map(&:display).join(' ') # print row of tiles
      str << " #{Board::SIDE_LENGTH - i}" # print current row number
      str << "\n"
    end
    str << '  '
    str << Board::COLUMN_TO_INDEX.keys.map(&:to_s).join(' ') # print columns
    str << "\n"
    str << dead_pieces_str(:Black)
    str << "Last move: #{@last_move}\n" unless @last_move.nil?
    puts str
  end

  # attempts to move the piece at origin to destination,
  # returns false if not possible, otherwise moves the piece and returns true
  def move_piece!(origin, destination)
    origin = Board.location_vector(origin) if origin.is_a? String
    destination = Board.location_vector(destination) if destination.is_a? String
    origin = Vector.new(origin) unless origin.is_a? Vector
    destination = Vector.new(destination) unless destination.is_a? Vector
    return false unless self[origin].occupied?
    return false unless Board.valid_position?(destination) && valid_path?(origin, destination)

    piece = self[origin].piece
    movement = destination - origin
    execute_enpassant(origin, movement) if enpassant_attempted?(origin, movement)
    if castling_attempted?(piece, movement)
      return false unless castling_allowed?(origin, movement)

      castle_rook(origin, movement)
    end
    piece = promote_pawn(piece, prompt_promotion_class) if promotion_allowed?(piece, destination)
    update_last_move(origin, destination)
    self[origin].pop!.move!
    replaced = self[destination].replace!(piece)
    @graveyard[replaced.color] << replaced unless replaced.nil? # add the dead piece to the graveyard
    true
  end

  # return the location vector associated with the Chess coordinate string
  def self.location_vector(coordinate)
    col, row = coordinate.split('')
    col = col.to_sym
    row = row.to_i
    array = [ROW_TO_INDEX[row], COLUMN_TO_INDEX[col]]
    raise KeyError, 'Invalid Chess co-ordinate!' unless Board.valid_coordinate?(coordinate)

    Vector.new(array)
  end

  # whether the Chess coordinate is valid
  def self.valid_coordinate?(coordinate)
    col, row = coordinate.split('')
    col = col.to_sym
    row = row.to_i
    array = [ROW_TO_INDEX[row], COLUMN_TO_INDEX[col]]
    array.none?(&:nil?)
  end

  # whether the king of given color is dead
  def king_is_dead?(color)
    @graveyard[color].any? { |piece| piece.is_a? King }
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
  def valid_pawn_path?(origin, destination, food = self[destination].piece)
    movement = destination - origin
    pawn = self[origin].piece
    step = (pawn.white? ? -1 : 1)
    if [[step, 1], [step, -1]].include?(movement.to_a)
      if enpassant_attempted?(origin, movement)
        enpassant_allowed?(origin, movement)
      else
        food && food.color != pawn.color
      end
    elsif movement == [2 * step, 0]
      !self[origin + Vector.new([step, 0])].occupied? && food.nil?
    else
      movement == [step, 0] && food.nil?
    end
  end

  # checks whether path is valid for general piece
  def valid_general_path?(origin, destination, food = self[destination].piece)
    movement = destination - origin
    piece = self[origin].piece
    return false unless piece.valid_move?(movement)

    steps = movement.to_a.map(&:abs).max
    step = movement / steps
    (1...steps).each do |i|
      pos = origin + step * i
      return false if self[pos].occupied?
    end
    !self[destination].occupied? || \
      (self[destination].occupied? && food == self[destination].piece && food.color != piece.color)
  end

  # returns the dead pieces of the given color as a string if there are dead-pieces, otherwise blank string
  def dead_pieces_str(color)
    if @graveyard[color].empty?
      String.new
    else
      "#{Piece::TEAM_ICONS[Piece.opposite(color)]}: #{@graveyard[color].map(&:symbol).join}\n"
    end
  end

  # returns whether the location is in danger of being attacked
  def spot_in_danger?(location, reference = location)
    ref_piece = self[reference].piece
    !enemies_attacking(location, ref_piece).empty?
  end

  # returns a list of the enemies attacking location
  def enemies_attacking(location, piece = self[location].piece)
    location = Vector.new(location) if location.is_a? Array
    color = piece.color
    # add any enemy knights to the list
    enemies = knight_spots_surrounding(location).filter do |spot|
      Board.valid_position?(spot) && self[spot].piece.is_a?(Knight) && self[spot].piece.color != color
    end
    # add general enemies attacking location
    tree = immediate_spots_surrounding(location)
    tree.filter! { |spot| Board.valid_position?(spot) } # filter out only spots on board
    tree.each do |spot|
      if self[spot].occupied? # if the spot has an enemy piece, add it and continue
        enemies += enemy_on(spot, location, piece)
        next
      end
      # otherwise
      diff = spot - location # the direction of the next spot
      step = diff.to_a.map(&:abs).max # the magnitude of diff
      next_spot = spot + diff / step # take a single-sized step toward the next spot
      tree << next_spot if Board.valid_position?(next_spot) # only add children if on board
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
  def enemy_on(spot, location, piece = self[location].piece)
    if self[spot].piece.is_a? Pawn
      return [spot] if valid_pawn_path?(spot, location, piece)
    else
      return [spot] if valid_general_path?(spot, location, piece)
    end
    []
  end

  # is a castling move being attempted?
  def castling_attempted?(king, movement)
    king.is_a?(King) && (movement == [0, 2] || movement == [0, -2])
  end

  # is castling allowed?
  def castling_allowed?(king_location, movement)
    king_row, king_col = king_location.to_a
    right = (movement == [0, 2])
    rook_col = (right ? Board::SIDE_LENGTH - 1 : 0)
    king = self[king_location].piece
    rook = self[king_row, rook_col].piece
    return false if !king.is_a?(King) || king.moved || !rook.is_a?(Rook) || rook.moved

    col_range = (right ? ((king_col + 1)...rook_col) : ((rook_col + 1)...king_col))
    # check if there is a clear path
    return false unless @grid[king_row][col_range].none?(&:occupied?)

    # check that no spot is in danger
    col_range.map { |col| spot_in_danger?(Vector.new([king_row, col]), king_location) }
  end

  # move rook in castling maneuver
  def castle_rook(king_location, movement)
    king_row, king_col = king_location.to_a
    right = (movement == [0, 2])
    rook_col = (right ? Board::SIDE_LENGTH - 1 : 0)
    # add rook movement to last move
    @last_move = "#{self[king_row, rook_col]} to #{self[king_row, king_col + (right ? 1 : -1)]}, "
    rook = self[king_row, rook_col].piece
    self[king_row, rook_col].pop!.move!
    self[king_row, king_col + (right ? 1 : -1)].replace!(rook) # move rook to the space next to castled King
  end

  # updates the last move recorded with a move from origin to destination
  def update_last_move(origin, destination)
    unless !@last_move.nil? && @last_move.end_with?(', ') # if a castling/enpassant move was made
      @last_move = String.new
    end
    @last_move += "#{self[origin]} to #{self[destination]}"
  end

  # is an en-passant being attempted?
  def enpassant_attempted?(origin, movement)
    _, horizontal = movement.to_a
    pawn = self[origin].piece
    target = self[origin + Vector.new([0, horizontal])].piece
    pawn.is_a?(Pawn) && !horizontal.zero? && target.is_a?(Pawn)
  end

  # is an en-passant allowed?
  def enpassant_allowed?(origin, movement)
    _, horizontal = movement.to_a
    pawn = self[origin].piece
    last_moves = parse_last_move
    return false if last_moves.length != 1

    start, fin = last_moves[0]
    _, piece = start
    fv = fin[0]
    correct_piece = (piece == (pawn.white? ? pawn.black_symbol : pawn.white_symbol))
    correct_location = (fv == origin + Vector.new([0, horizontal]))
    correct_piece && correct_location
  end

  # execute an en-passant maneuver
  def execute_enpassant(origin, movement)
    _, horizontal = movement.to_a
    target = self[origin + Vector.new([0, horizontal])]
    @last_move = "killed #{target}, "
    target_piece = target.pop!
    @graveyard[target_piece.color] << target_piece # add captured pawn to graveyard
  end

  # parse last_move to get a list of vectors denoting move locations
  def parse_last_move
    moves = @last_move.split(', ')
    moves.map! { |move| move.split(' to ') }
    moves.map! do |move|
      move.map! do |coord|
        if Board.valid_coordinate?(coord[-2..-1])
          if Board::COLUMN_TO_INDEX.key?(coord[0].to_sym)
            [Board.location_vector(coord[-2..-1])]
          else
            [Board.location_vector(coord[-2..-1]), coord[0]]
          end
        end
      end
    end
    moves.map { |move| move.reject(&:nil?) }
  end

  # is promotion of the piece moving to destination allowed?
  def promotion_allowed?(piece, destination)
    eigth_rank = (piece.white? ? 0 : Board::SIDE_LENGTH - 1)
    vertical, = destination.to_a

    piece.is_a?(Pawn) && vertical == eigth_rank
  end

  # promote the pawn to the given class
  def promote_pawn(pawn, piece)
    new_piece = piece.new(pawn.color)
    new_piece.move!
    @last_move = "#{pawn.symbol}->#{new_piece.symbol}, "
    new_piece
  end

  # request selection of promotion class
  def prompt_promotion_class
    classes = { 1 => Queen, 2 => Rook, 3 => Bishop, 4 => Knight }.freeze
    puts 'Select promotion class by choosing a number between 1-4:'
    puts classes
    classes[gets.chomp.to_i]
  end
end

# Implements a Chessboard Tile
class Tile
  WHITE_EMPTY_SYMBOL = '.'
  GRAY_EMPTY_SYMBOL = '.'

  attr_reader :piece

  def initialize(row, col, gray = false)
    @gray = gray
    @piece = nil
    @row = row
    @col = col
  end

  # whether the Tile is occupied
  def occupied?
    @piece != nil
  end

  # shows the empty Tile symbol if empty, otherwise shows the piece symbol
  def display
    empty_symbol = (@gray ? Tile::GRAY_EMPTY_SYMBOL : Tile::WHITE_EMPTY_SYMBOL)
    occupied? ? @piece.symbol : empty_symbol
  end

  # shows a string representing the piece and the coordinate
  def to_s
    str = String.new
    str << "#{@piece.symbol}" if occupied?
    str << "#{@col}#{@row}"
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
