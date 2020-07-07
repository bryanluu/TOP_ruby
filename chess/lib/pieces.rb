# frozen_string_literal: true

require_relative 'board'
require_relative 'vector'
require 'pry'

# Implements a Chess piece
class Piece
  attr_reader :position, :symbol, :color
  COLORS = %i[White Black].freeze
  @@black_symbol = nil
  @@white_symbol = nil

  def initialize(board, position, color = :White)
    @board = board
    @position = position
    @active = true
    @moveset = []
    @color = color
    @symbol = (color == :White ? @@white_symbol : @@black_symbol)
  end

  # whether the piece is on the board
  def active?
    @active
  end

  # returns false if destination cannot be reached, otherwise moves piece and returns true
  def move_to!(destination)
    movement = destination - position

    return false unless @board.valid_position?(destination) && valid_move?(movement)

    @position = destination
    true
  end

  # de-activates piece
  def kill!
    @active = false
  end

  # creates a string representation
  def to_s
    symbol.to_s + (active? ? "@#{position}" : '')
  end

  # checks whether the move is valid for the piece
  def valid_move?(movement)
    @moveset.empty? || @moveset.include?(movement)
  end
end

# Implements a King
class King < Piece
  @@black_symbol = "\u265A"
  @@white_symbol = "\u2654"
  @@black_symbol.freeze
  @@white_symbol.freeze

  def initialize(board, position, color)
    super(board, position, color)
    steps = [-1, 0, 1]
    moves = steps.product(steps) # the single steps around current position
    moves.delete([0, 0]) # delete current position
    @moveset = moves.map { |move| Vector.new(move) } # convert moves into Vectors
  end
end

# Implements a Queen
class Queen < Piece
  @@black_symbol = "\u265B"
  @@white_symbol = "\u2655"
  @@black_symbol.freeze
  @@white_symbol.freeze

  def initialize(board, position, color)
    super(board, position, color)
    steps = Array(1...Board::SIDE_LENGTH)
    steps = steps.reverse.map(&:-@) + steps
    horizontal = steps.map { |step| Vector.new([0, step]) }
    vertical = steps.map { |step| Vector.new([step, 0]) }
    diagonal = steps.map { |step| Vector.new([step, step]) }
    antidiagonal = steps.map { |step| Vector.new([step, -step]) }
    @moveset = horizontal + vertical + diagonal + antidiagonal
  end
end

# Implements a Rook
class Rook < Piece
  @@black_symbol = "\u265C"
  @@white_symbol = "\u2656"
  @@black_symbol.freeze
  @@white_symbol.freeze

  def initialize(board, position, color)
    super(board, position, color)
    steps = Array(1...Board::SIDE_LENGTH)
    steps = steps.reverse.map(&:-@) + steps
    horizontal = steps.map { |step| Vector.new([0, step]) }
    vertical = steps.map { |step| Vector.new([step, 0]) }
    @moveset = horizontal + vertical
  end
end

# binding.pry
