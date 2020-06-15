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

  def initialize(colors)
    @row = colors
  end
end

class Key
  COLORS = { 0 => :black,
             1 => :white }.freeze
end

# Class that represents a Decoding Board
class Board
  def initialize(code)
    @code = code
  end

  def get_feedback(code)
    cmp = []
    code.each_with_index do |x, i|
      cmp.push(x) if x == @code[i]
    end
    puts cmp
  end
end

binding.pry