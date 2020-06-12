require 'pry'

# Tic-Tac-Toe square
class Square
  attr_reader :symbol
  def initialize
    @symbol = nil
  end

  def empty?
    symbol == nil
  end

  def symbol=(sym)
    if empty? # if square is empty
      @symbol = sym
    else
      puts 'Square already has symbol!'
    end
  end
end

# Tic-Tac-Toe board
class Board
  def initialize
    @turn_number = 0
    @board = [[], [], []]
    for i in 0...3
      for j in 0...3
        @board[i].push(Square.new)
      end
    end
  end

  # print the board to stdout
  def to_s
    str = ''
    for row in 0...3
      for col in 0...3
        str += (@board[row][col].empty? ? '.' : @board[row][col].symbol)
      end
      str += "\n"
    end
    str
  end

  # checks whether coordinate is valid
  def valid_coord?(row, col)
    (0...3).include?(row) && (0...3).include?(col)
  end

  def set_x(row, col)
    @turn_number += 1
    set_to_symbol('x', row, col)
  end

  def set_o(row, col)
    set_to_symbol('o', row, col)
  end

  def winner
    return nil unless @turn_number >= 3

    directions = %i[horizontal vertical
                    diagonal antidiagonal]
    victor = nil
    for dir in directions
      victor = check_win(dir)
      if victor
        return victor
      end
    end
  end

  private

  def set_to_symbol(symbol, row, col)
    return puts 'Out of range' unless valid_coord?(row, col)

    if @board[row][col].empty?
      @board[row][col].symbol = symbol
    else
      puts 'Square already has symbol!'
      return nil
    end
  end

  def check_row_equal(row)
    if @board[row][0].symbol == @board[row][1].symbol &&
       @board[row][0].symbol == @board[row][2].symbol
      return @board[row][0].symbol
    else
      return nil
    end
  end

  def check_col_equal(col)
    if @board[0][col].symbol == @board[1][col].symbol &&
       @board[0][col].symbol == @board[2][col].symbol
      return @board[0][col].symbol
    else
      return nil
    end
  end

  def check_diagonal_equal
    if @board[0][0].symbol == @board[1][1].symbol &&
       @board[0][0].symbol == @board[2][2].symbol
      return @board[0][0].symbol
    else
      return nil
    end
  end

  def check_antidiagonal_equal
    if @board[2][0].symbol == @board[1][1].symbol &&
       @board[2][0].symbol == @board[0][2].symbol
      return @board[1][1].symbol
    else
      return nil
    end
  end

  def check_win(direction)
    victor = nil
    # check along direction
    for i in 0...3
      victor = case direction
               when :horizontal then check_row_equal(i)
               when :vertical then check_col_equal(i)
               when :diagonal then check_diagonal_equal
               when :antidiagonal then check_antidiagonal_equal
               end
      if victor # if victor is found
        return victor
      elsif direction == :diagonal || direction == :antidiagonal
        return nil
      end
    end
    return nil
  end
end

binding.pry