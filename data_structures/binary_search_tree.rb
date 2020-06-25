# frozen_string_literal: true

# Class that implements a Binary-Search-Tree (BST) Node
class Node
  include Comparable
  attr_reader :data
  attr_accessor :left, :right

  def initialize(data)
    @data = data
    @left = nil
    @right = nil
  end

  def <=>(other)
    data <=> other.data
  end

  def inspect
    @data.inspect
  end
end
