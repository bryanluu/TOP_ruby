# frozen_string_literal: true

require_relative 'board'
require_relative 'vector'

# Implements a Chess piece
class Piece
  attr_reader :position, :symbol, :color
  COLORS = %i[White Black].freeze
  TEAM_ICONS = { White: "\u2690", Black: "\u2691" }.freeze

  def initialize(color = :White)
    @active = true
    @moveset = []
    @color = color
    @symbol = (color == :White ? white_symbol : black_symbol)
  end

  # do nothing by default
  def move!; end

  # get a frozen copy of moveset
  def moves
    @moveset[0..-1].freeze
  end

  def white_symbol
    nil
  end

  def black_symbol
    nil
  end

  # whether the piece is on the board
  def active?
    @active
  end

  # de-activates piece
  def kill!
    @active = false
  end

  # checks whether the move is valid for the piece
  def valid_move?(movement)
    @moveset.empty? || @moveset.include?(movement)
  end

  # whether the piece is white
  def white?
    color == :White
  end

  # whether the piece is black
  def black?
    color == :Black
  end

  # the opposite team's color
  def self.opposite(color)
    Piece::COLORS[(Piece::COLORS.index(color) + 1) % 2]
  end
end

# Implements a King
class King < Piece
  attr_reader :moved

  def initialize(color)
    super(color)
    steps = [-1, 0, 1]
    moves = steps.product(steps) # the single steps around current position
    moves.delete([0, 0]) # delete current position
    @moveset = moves.map { |move| Vector.new(move) } # convert moves into Vectors
    @moveset << Vector.new([0, 2]) << Vector.new([0, -2]) # add castling moves
    @moved = false
  end

  def move!
    unless @moved
      @moveset.delete(Vector.new([0, -2]))
      @moveset.delete(Vector.new([0, 2]))
      @moved = true
    end
  end

  def white_symbol
    "\u2654"
  end

  def black_symbol
    "\u265A"
  end
end

# Implements a Queen
class Queen < Piece
  def initialize(color)
    super(color)
    steps = Array(1...Board::SIDE_LENGTH)
    steps = steps.reverse.map(&:-@) + steps
    horizontal = steps.map { |step| Vector.new([0, step]) }
    vertical = steps.map { |step| Vector.new([step, 0]) }
    diagonal = steps.map { |step| Vector.new([step, step]) }
    antidiagonal = steps.map { |step| Vector.new([step, -step]) }
    @moveset = horizontal + vertical + diagonal + antidiagonal
  end

  def white_symbol
    "\u2655"
  end

  def black_symbol
    "\u265B"
  end
end

# Implements a Rook
class Rook < Piece
  attr_reader :moved

  def initialize(color)
    super(color)
    steps = Array(1...Board::SIDE_LENGTH)
    steps = steps.reverse.map(&:-@) + steps
    horizontal = steps.map { |step| Vector.new([0, step]) }
    vertical = steps.map { |step| Vector.new([step, 0]) }
    @moveset = horizontal + vertical
    @moved = false
  end

  def move!
    @moved = true
  end

  def white_symbol
    "\u2656"
  end

  def black_symbol
    "\u265C"
  end
end

# Implements a Bishop
class Bishop < Piece
  def initialize(color)
    super(color)
    steps = Array(1...Board::SIDE_LENGTH)
    steps = steps.reverse.map(&:-@) + steps
    diagonal = steps.map { |step| Vector.new([step, step]) }
    antidiagonal = steps.map { |step| Vector.new([step, -step]) }
    @moveset = diagonal + antidiagonal
  end

  def white_symbol
    "\u2657"
  end

  def black_symbol
    "\u265D"
  end
end

# Implements a Knight
class Knight < Piece
  def initialize(color)
    super(color)
    moves = [1, -1].product([2, -2])
    moves += moves.map(&:reverse)
    @moveset = moves.map { |move| Vector.new(move) }
  end

  def white_symbol
    "\u2658"
  end

  def black_symbol
    "\u265E"
  end
end

# Implements a Pawn
class Pawn < Piece
  attr_reader :moved

  def initialize(color)
    super(color)
    step = (white? ? -1 : 1)
    moves = [[step, 0], [step, 1], [step, -1], [2 * step, 0]]
    @moveset = moves.map { |move| Vector.new(move) }
    @moved = false
  end

  def white_symbol
    "\u2659"
  end

  def black_symbol
    "\u265F"
  end

  def move!
    return if @moved

    @moved = true
    step = (white? ? -1 : 1)
    @moveset.delete([2 * step, 0])
  end
end
