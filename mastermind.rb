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
    check = code.row[0..-1] # copy code
    count.each do |k, v|
      # push a white peg for all pegs included in code
      v.times { feedback << 1 and check.delete_at(check.index(k)) if check.include?(k) }
    end
    code.row.each_with_index do |x, i|
      # prepend a red peg and remove a white peg for correct pegs in code
      feedback.unshift(2) and feedback.pop if x == @row[i]
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
    @code.compare(guessed)
  end

  def win?(code)
    guessed = Code.new(code)
    guessed.correct? @code
  end

  def lose?
    @turns > MAX_TURNS
  end

end

# Game of Mastermind
class Game
  def initialize(repeats_allowed = false, codemaker_cpu = true)
    @repeats_allowed = repeats_allowed
    @codemaker_cpu = codemaker_cpu
  end

  # generate a code
  def generate_code(cpu = false)
    if cpu
      if @repeats_allowed
        code = []
        4.times { code << Code::COLORS.keys.sample }
      else
        Code::COLORS.keys.sample(4)
      end
    else
      prompt_code
    end
  end

  private

  def prompt_code
    puts Code::COLORS
    puts 'Enter a code using integers from 0 to 5, separated by spaces:'
    trialcode = gets.chomp.split.map(&:to_i)
    return trialcode if @repeats_allowed

    while has_repeats?(trialcode)
      puts 'No repeats allowed!'
      puts Code::COLORS
      puts 'Enter a code using integers from 0 to 5, separated by spaces:'
      trialcode = gets.chomp.split.map(&:to_i)
    end
  end

  # whether anything repeats in array
  def has_repeats?(array)
    array.uniq.length < array.length
  end
end

b = Board.new([1, 1, 1, 0])
c = [1, 1, 1, 0]
b.guess(c)

binding.pry