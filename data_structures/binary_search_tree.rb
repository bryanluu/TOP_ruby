# frozen_string_literal: true

require 'pry'

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

# Implements a Binary-Search-Tree (BST)
class Tree
  attr_reader :root

  def initialize(array)
    @root = build_tree(array)
  end

  # builds a balanced tree from array
  def build_tree(array)
    return nil if array.empty?

    a = array.sort.uniq
    mid = a.length / 2
    node = Node.new(a[mid])
    node.left = build_tree(a[0...mid])
    node.right = build_tree(a[mid+1..-1])
    node
  end

  # insert value into the tree and return root
  def insert(value)
    node = Node.new(value)
    return (@root = node) if root.nil?

    curr = root
    loop do
      if node < curr
        if curr.left.nil?
          curr.left = node
          break
        else
          curr = curr.left
        end
      else
        if curr.right.nil?
          curr.right = node
          break
        else
          curr = curr.right
        end
      end
    end
    root
  end

  # delete value from tree and return root
  def delete(value)
    return nil if root.nil?

    parent = nil
    curr = root
    until value == curr.value
      return nil if curr.nil? # value not present in BST

      parent = curr
      curr = (value < curr.value ? curr.left : curr.right)
    end

    if curr == root
      if curr.left.nil? && curr.right.nil?
        @root = nil
      elsif curr.left.nil?
        @root = curr.right
      elsif curr.right.nil?
        @root = curr.left
      else
        min_parent = curr
        min = curr.right
        until min.left.nil?
          min_parent = min
          min = min.left
        end
        @root = Node.new(min.value)
        root.left = curr.right.left
        root.right = curr.right.right
        min_parent.left = nil
      end
      return root
    end

    if parent.left == curr
      if curr.left.nil? && curr.right.nil?
        parent.left = nil
      elsif curr.left.nil?
        parent.left = curr.right
      elsif curr.right.nil?
        parent.left = curr.left
      else
        min_parent = curr
        min = curr.left
        until min.right.nil?
          min_parent = min
          min = min.right
        end
        node = Node.new(min.value)
        node.left = curr.left.left
        node.right = curr.left.right
        parent.left = node
        min_parent.right = nil
      end
    else
      if curr.left.nil? && curr.right.nil?
        parent.right = nil
      elsif curr.left.nil?
        parent.right = curr.right
      elsif curr.right.nil?
        parent.right = curr.left
      else
        min_parent = curr
        min = curr.right
        until min.left.nil?
          min_parent = min
          min = min.left
        end
        node = Node.new(min.value)
        node.left = curr.right.left
        node.right = curr.right.right
        parent.right = node
        min_parent.left = nil
      end
    end
    root
  end

  # Find and return the node with the given value, otherwise return nil if not found.
  def find(value)
    return nil if root.nil?

    curr = root
    loop do
      return nil if curr.nil?
      return curr if value == curr.value

      curr = (value < curr.value ? curr.left : curr.right)
    end
  end

  # Yields nodes in level-order of the BST to the block if given, returns a level-order array of nodes
  def level_order
    return nil if root.nil?

    q = [root] # queue for breath-first traversal
    level_order_array = []
    until q.empty?
      node = q.shift
      q.push(node.left) unless node.left.nil?
      q.push(node.right) unless node.right.nil?
      level_order_array.push(node)
      yield node if block_given?
    end
    level_order_array
  end

  # Yields nodes inorder of BST if block is given, returns as inorder array of nodes
  def inorder
    return nil if root.nil?

    stack = [] # stack
    inorder_array = []
    curr = root
    until curr.nil? && stack.empty?
      # go leftward until curr is nil
      until curr.nil?
        stack.push(curr)
        curr = curr.left
      end
      # curr is nil
      curr = stack.pop # get new node from call stack
      # process node
      yield curr if block_given?
      inorder_array.push(curr)
      # travel right
      curr = curr.right
    end
    inorder_array
  end

  # Yields nodes preorder of BST if block is given, returns as preorder array of nodes
  def preorder
    return nil if root.nil?

    stack = [root] # stack
    preorder_array = []
    until stack.empty?
      curr = stack.pop # get new node from call stack
      # process node
      yield curr if block_given?
      preorder_array.push(curr)
      # push children onto stack so that left child is processed first
      stack.push(curr.right) unless curr.right.nil?
      stack.push(curr.left) unless curr.left.nil?
    end
    preorder_array
  end

  # Yields nodes postorder of BST if block is given, returns as postorder array of nodes
  def postorder
    return nil if root.nil?

    stack = [root] # stack
    postorder_array = [] # use this as a second 'stack'
    until stack.empty?
      curr = stack.pop # get new node from call stack
      postorder_array.push(curr) # push onto second 'stack'
      # push children onto stack
      stack.push(curr.left) unless curr.left.nil?
      stack.push(curr.right) unless curr.right.nil?
    end
    postorder_array.reverse! # reverse array to get postorder
    postorder_array.each { |node| yield node } if block_given?
    postorder_array
  end
end

binding.pry
