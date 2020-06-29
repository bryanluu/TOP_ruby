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
  @@adj_list = {} # adjacency list of possible moves for the entire board

  def initialize(position)
    @position = position
    @history = [position]
  end

  def move_to(position)
    return nil unless Knight.valid_move?(@position, position)

    @position = position
    history << position
  end

  # checks if the knight can move to the given position
  def self.valid_move?(origin, destination)
    horizontal_movement = destination.first - origin.first
    vertical_movement = destination.last - origin.last
    ((horizontal_movement.abs == 1 && vertical_movement.abs == 2) || \
      (horizontal_movement.abs == 2 && vertical_movement.abs == 1)) && \
      destination.first.between?(0, 7) && destination.last.between?(0, 7)
  end

  # gets list of possible different positions to move to from given position
  def self.possible_moves_from(position)
    movable_spots = []
    movable_spots << [position.first + 1, position.last + 2]
    movable_spots << [position.first + 1, position.last - 2]
    movable_spots << [position.first - 1, position.last + 2]
    movable_spots << [position.first - 1, position.last - 2]
    movable_spots << [position.first + 2, position.last + 1]
    movable_spots << [position.first + 2, position.last - 1]
    movable_spots << [position.first - 2, position.last + 1]
    movable_spots << [position.first - 2, position.last - 1]
    movable_spots.select { |destination| valid_move?(position, destination) }
  end

  private

  # gets list of possible different positions to move to from knight's position
  def possible_moves
    Knight.possible_moves_from(@position)
  end

  # populate the adjacency list of moves
  range = Array(0...8)
  positions = range.product(range)
  positions.each do |pos|
    @@adj_list[pos] = possible_moves_from(pos)
  end

  public

  # find the shortest path to the destination from Knight's position
  def shortest_path_to(destination)
    q = [[position]] # queue for BFS, initialized with Knight's current position-path
    until q.empty?
      path = q.shift # get next path
      curr = path.last # get curr node
      return path if curr == destination # successfully found the shortest path to destination

      # add children of the current position
      @@adj_list[curr].each { |next_dest| q << path + [next_dest] }
    end
  end
end

# Returns the shortest path a knight can take from origin to destination
def knight_moves(origin, destination)
  board = Board.new(origin)
  shortest_path = board.knight.shortest_path_to(destination)
  shortest_path[1..-1].each { |pos| board.knight.move_to(pos) }
  puts "Knight can take #{shortest_path.length} moves to get there:"
  p shortest_path
  puts board
end

puts "Enter the Knight's origin as two numbers between 0-7 spaced apart:"
origin = gets.chomp.split.map(&:to_i)
puts "Enter the Knight's destination as two numbers between 0-7 spaced apart:"
destination = gets.chomp.split.map(&:to_i)
knight_moves(origin, destination)
