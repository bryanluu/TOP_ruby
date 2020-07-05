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

  # checks whether the move is valid for the piece
  def valid_move?(movement)
    @moveset.empty? || @moveset.include?(movement)
  end

  # de-activates piece
  def kill!
    @active = false
  end

  # creates a string representation
  def to_s
    symbol.to_s + (active? ? "@#{position}" : '')
  end
end

# Implements a King
class King < Piece
  @@black_symbol = "\u265B"
  @@white_symbol = "\u2655"
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

# binding.pry
