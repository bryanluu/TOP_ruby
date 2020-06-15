require 'pry'

# Class that represents a code
class Code
  COLORS = { 0 => :black,
             1 => :white,
             2 => :red,
             3 => :blue,
             4 => :green,
             5 => :yellow }.freeze

  attr_reader :row

  def initialize(code)
    @row = []
    code.each { |x| @row << COLORS[x] }
  end

  def to_s
    @row.to_s
  end

  # returns a counter hash
  def count
    map = {}
    COLORS.values.each { |v| map[v] = 0 }
    @row.each do |x|
      map[x] = map[x] + 1
    end
    map
  end

  def compare(code)
    feedback = []
    check = code.row[0..-1]
    count.each do |k, v|
      # push a white peg for all pegs included in code
      (0...v).each { feedback << 1 and check.delete_at(check.index(k)) if check.include?(k) }
    end
    code.row.each_with_index do |x, i|
      # prepend a black peg and remove a white peg for correct pegs in code
      feedback.unshift(0) and feedback.pop if x == @row[i]
    end
    feedback.map! { |x| COLORS[x] } # map to colors
  end

  def correct?(code)
    @row == code.row
  end
end

# Class that represents a Decoding Board
class Board
  MAX_TURNS = 12

  def initialize(code)
    @code = Code.new(code)
    @turns = 0
  end

  def guess(code)
    @turns += 1
    guessed = Code.new(code)
    puts 'Guess:'
    puts guessed
    puts 'Feedback:'
    feedback = @code.compare(guessed)
    puts feedback
    puts 'You win!' if (@turns <= MAX_TURNS) && (guessed.correct? @code)
    puts 'You lose!' if @turns > MAX_TURNS
    feedback
  end
end

b = Board.new([1, 1, 1, 0])
c = [1, 1, 1, 0]
b.guess(c)

# binding.pry