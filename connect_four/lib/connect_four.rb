# frozen_string_literal: true

class Cage
  attr_reader :array
  @@empty_symbol = "\u23F9"
  @@white_token = "\u26AA"
  @@black_token = "\u26AB"
  @@rows = 6
  @@columns = 7

  def self.empty_symbol
    @@empty_symbol
  end

  def self.white_token
    @@white_token
  end

  def self.black_token
    @@black_token
  end

  def initialize
    @array = Array.new(@@rows) { Array.new(@@columns) { @@empty_symbol } }
    @white_turn = true
  end

  def to_s
    rows = []
    array.each do |row|
      rows << row.join
    end
    rows.join("\n")
  end

  def turn
    @white_turn ? 'White' : 'Black'
  end

  def drop!(column)
    return false if column_full?(column)

    row = @@rows-1
    row -= 1 until spot_empty?(row, column)
    @array[row][column] = (@white_turn ? Cage.white_token : Cage.black_token)
    @white_turn = !@white_turn # toggle turn
    true
  end

  def column_full?(column)
    array.all? { |row| row[column] != Cage.empty_symbol }
  end

  def empty?
    array.all? { |row| row.all? { |token| token == Cage.empty_symbol } }
  end

  def reset!
    @array = Array.new(@@rows) { Array.new(@@columns) { @@empty_symbol } }
    @white_turn = true
  end

  # returns true if somebody won, otherwise returns false
  def connects_four?
    i = -1
    # scan through the cage and check if there is a four
    while i < @@rows * @@columns
      column = (i += 1) % @@columns
      row = @@rows - 1 - (i / @@columns)

      unless spot_empty?(row, column)
        return true if token_makes_horizontal_four?(row, column)
        return true if token_makes_vertical_four?(row, column)
        return true if token_makes_diagonal_four?(row, column)
        return true if token_makes_antidiagonal_four?(row, column)
      end
    end
    false
  end

  private

  def spot_empty?(row, column)
    array[row][column] == Cage.empty_symbol
  end

  def token_makes_horizontal_four?(row, column)
    return false if column > @@columns - 4

    token = array[row][column]
    (column...column + 4).all? { |col| array[row][col] == token }
  end

  def token_makes_vertical_four?(row, column)
    return false if row < 3

    token = array[row][column]
    array[row - 3..row].all? { |r| r[column] == token }
  end

  def token_makes_diagonal_four?(row, column)
    return false if row < 3 || column > @@columns - 4

    token = array[row][column]
    tokens = []
    (0...4).each do |i|
      tokens << array[row - i][column + i]
    end
    tokens.all? { |t| t == token }
  end

  def token_makes_antidiagonal_four?(row, column)
    return false if row < 3 || column < 3

    token = array[row][column]
    tokens = []
    (0...4).each do |i|
      tokens << array[row - i][column - i]
    end
    tokens.all? { |t| t == token }
  end
end