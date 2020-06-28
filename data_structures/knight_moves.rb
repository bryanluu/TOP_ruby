# frozen_string_literal: true

require 'pry'

# Class that implements a Chess-Board
class Board
  attr_reader :board, :knight

  def initialize(position)
    @board = []
    8.times do
      row = []
      (0...8).each do |_|
        row << '.'
      end
      @board << row
    end
    @knight = Knight.new(position)
  end

  def print
    puts board
  end

  def to_s
    knight.history.each_with_index do |position, turn|
      board[position.first][position.last] = turn.to_s
    end
    str = String.new
    (0...8).each do |row|
      (0...8).each do |col|
        str += board[row][col]
      end
      str += "\n"
    end
    str
  end
end

# Class that implements a Chess Knight
class Knight
  attr_accessor :position
  attr_reader :history

  def initialize(position)
    @position = position
    @history = [position]
  end

  def move_to(position)
    return nil unless valid_move? position

    @position = position
    history << position
  end

  def valid_move?(position)
    horizontal_movement = position.first - @position.first
    vertical_movement = position.last - @position.last
    (horizontal_movement.abs == 1 && vertical_movement.abs == 2) || \
      (horizontal_movement.abs == 2 && vertical_movement.abs == 1)
  end
end

binding.pry
