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
    row = []
    code.each { |x| row << COLORS[x] }
  end

  def to_s
    row.to_s
  end

  # returns a counter hash
  def count
    map = {}
    COLORS.values.each { |v| map[v] = 0 }
    row.each do |x|
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
      feedback.unshift(2) and feedback.pop if x == row[i]
    end
    feedback
  end

  def correct?(code)
    row == code.row
  end
end

# Class that represents a Decoding Board
class Board
  MAX_TURNS = 12

  attr_reader :code, :turns

  def initialize(code)
    code = Code.new(code)
    turns = 0
  end

  def guess(code)
    turns += 1
    puts "Turn: #{turns}"
    guessed = Code.new(code)
    puts 'Guess:'
    puts guessed
    puts 'Feedback:'
    feedback = code.compare(guessed)
    p(feedback.map { |x| Code::COLORS[x] })
    puts 'Press enter to continue...'
    gets
    feedback
  end

  def code_broken?(code)
    guessed = Code.new(code)
    guessed.correct? code
  end

  def out_of_turns?
    turns >= MAX_TURNS
  end
end

# Game of Mastermind
class Game
  attr_reader :repeats_allowed
  attr_accessor :unused_codes, :codeset, :codemaker_cpu, :codebreaker_cpu
  def initialize
    repeats_allowed, codemaker_cpu, codebreaker_cpu = prompt_config
    @repeats_allowed = repeats_allowed
    @codemaker_cpu = codemaker_cpu
    @codebreaker_cpu = codebreaker_cpu
    @unused_codes = nil
    @codeset = nil
  end

  def play
    puts "=== Codemaker's Turn ==="
    board = Board.new(generate_code)
    puts "=== Codebreaker's Turn ==="
    code = guess_code
    feedback = board.guess(code)
    until board.code_broken?(code) || board.out_of_turns?
      code = guess_code(code, feedback)
      feedback = board.guess(code)
    end
    end_game(board)
  end

  private

  # generates all possible codes for Knuth algorithm
  def all_possible_codes
    colors = Code::COLORS.keys
    colors.product(colors, colors, colors)
  end

  # removal step for Knuth algorithm
  def purge_code_set(codeset, guess, feedback)
    code = Code.new(guess)
    s = codeset[0..-1] # copy codeset
    codeset.each do |x|
      c = Code.new(x)
      s.delete(x) if code.compare(c) != feedback
    end
    s
  end

  # minmax step for Knuth algorithm
  def minimax(codeset, unused_codes)
    minmax = codeset.length + 1 # largest max possible
    codes = nil
    unused_codes.each do |i|
      g = Code.new(i)
      table = {} # table of feedback hits
      max = -1
      codeset.each do |j|
        c = Code.new(j)
        s = c.compare(g) # feedback from c compared with g
        table[s] = table.fetch(s, 0) + 1
        max = table[s] if table[s] > max
      end
      if max < minmax
        codes = [i] # add new minimax to empty list
        minmax = max
      elsif max == minmax
        codes << i # add solution to minimax list
      end
    end
    codes
  end

  # get a Knuth solution from the set
  def get_next_knuth_code(codes)
    codes.each { |c| return c if codeset.include?(c) }
    codes.each { |c| return c if unused_codes.include?(c) }
    codes[0] # never reached
  end

  # Knuth solution
  def guess_knuth(guess, feedback)
    if unused_codes.nil?
      unused_codes = all_possible_codes
      unused_codes.delete(guess)
      codeset = purge_code_set(unused_codes, guess, feedback)
    else
      codeset = purge_code_set(codeset, guess, feedback)
    end
    codes = minimax(codeset, unused_codes)
    code = get_next_knuth_code(codes)
    unused_codes.delete(code)
  end

  # prompt config
  def prompt_config
    puts 'Allow repeats?'
    repeats = affirmative?
    puts 'CPU Codemaker?'
    codemaker_cpu = affirmative?
    puts 'CPU Codebreaker?'
    codebreaker_cpu = affirmative?
    [repeats, codemaker_cpu, codebreaker_cpu]
  end

  def affirmative?
    input = gets.chomp.downcase
    %w[y yes].include? input
  end

  # end game
  def end_game(board)
    puts board.out_of_turns? ? 'Codemaker wins!' : 'Codebreaker wins!'
    puts "Code: #{board.code}"
  end

  # generate a guess for the code
  def guess_code(guess=nil, feedback=nil)
    if codebreaker_cpu
      if guess.nil? || feedback.nil?
        random_code
      else
        guess_knuth(guess, feedback)
      end
    else
      prompt_code
    end
  end

  # generate a code
  def generate_code
    if codemaker_cpu
      puts 'Code chosen by CPU.'
      random_code
    else
      prompt_code
    end
  end

  # generates a random code
  def random_code
    if repeats_allowed
      code = []
      4.times { code << Code::COLORS.keys.sample }
      code
    else
      Code::COLORS.keys.sample(4)
    end
  end

  # prompts user for input for a code
  def prompt_code
    code_prompt
    trialcode = gets.chomp.split.map(&:to_i)
    return trialcode if repeats_allowed

    while has_repeats?(trialcode)
      puts 'No repeats allowed!'
      code_prompt
      trialcode = gets.chomp.split.map(&:to_i)
    end
    trialcode
  end

  # code prompt
  def code_prompt
    puts Code::COLORS
    puts 'Enter a code using integers from 0 to 5, separated by spaces:'
  end

  # whether anything repeats in array
  def has_repeats?(array)
    array.uniq.length < array.length
  end
end

g = Game.new
g.play