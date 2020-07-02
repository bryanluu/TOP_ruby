# frozen_string_literal: true

class Cage
  attr_reader :array
  @@empty_symbol = "⚪"
  @@red_token = "🔴"
  @@yellow_token = "🟡"
  @@rows = 6
  @@columns = 7

  def self.empty_symbol
    @@empty_symbol
  end

  def self.red_token
    @@red_token
  end

  def self.yellow_token
    @@yellow_token
  end

  def initialize
    @array = Array.new(@@rows) { Array.new(@@columns) { @@empty_symbol } }
    @red_turn = true
  end

  def to_s
    rows = []
    array.each do |row|
      rows << row.join
    end
    rows.join("\n")
  end

  def turn
    @red_turn ? 'Red' : 'Yellow'
  end

  def drop!(column)
    return false if column_full?(column)

    row = @@rows-1
    row -= 1 until spot_empty?(row, column)
    @array[row][column] = (@red_turn ? Cage.red_token : Cage.yellow_token)
    @red_turn = !@red_turn # toggle turn
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
    @red_turn = true
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

  def winner
    return 'Nobody' unless connects_four?

    @red_turn ? 'Yellow' : 'Red'
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

class Game
  def initialize
    @cage = Cage.new
  end

  def play
    continue = true
    while continue
      play_single_token until @cage.connects_four?
      puts @cage
      puts "#{@cage.winner} wins!"
      puts 'Play again?'
      continue = affirmative?
      @cage.reset! if continue
    end
  end

  private

  def input_column
    column = gets.chomp.to_i
    until column.between?(0, @cage.array.length)
      puts 'Invalid column! Must be in the range (0-6). Try again:'
      column = gets.chomp.to_i
    end
    column
  end

  def affirmative?
    input = gets.chomp.downcase
    %w[y yes].include? input
  end

  def play_single_token
    puts @cage
    puts "Enter column (0-6), #{@cage.turn}:"
    @cage.drop!(input_column)
  end
end

if __FILE__ == $0
  game = Game.new
  game.play
end