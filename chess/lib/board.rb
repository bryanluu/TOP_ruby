# frozen_string_literal: true

class Board
  SIDE_LENGTH = 8

  def initialize

  end

  def valid_position?(position)
    row, col = position.to_a
    row.between?(0, Board::SIDE_LENGTH - 1) && col.between?(0, Board::SIDE_LENGTH - 1)
  end
end