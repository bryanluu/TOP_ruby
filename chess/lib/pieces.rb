# frozen_string_literal: true

require 'board'
require 'vector'

class Piece
  attr_reader :position
  @@moveset = []
  @@symbol = nil

  def initialize(board, position)
    @board = board
    @position = position
    @active = true
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
    @@moveset.empty? || @@moveset.include?(movement)
  end

  # de-activates piece
  def kill!
    @active = false
  end

  # returns the symbol
  def symbol
    @@symbol
  end

  # creates a string representation
  def to_s
    symbol.to_s + (active? ? "@#{position}" : '')
  end
end
