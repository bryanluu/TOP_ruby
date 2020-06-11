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
end

binding.pry