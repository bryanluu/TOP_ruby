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

    return nil unless find(value).nil?

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
    until value == curr.data
      return nil if curr.nil? # value not present in BST

      parent = curr
      curr = (value < curr.data ? curr.left : curr.right)
    end

    if curr == root
      if curr.left.nil? && curr.right.nil?
        @root = nil
      elsif curr.left.nil?
        @root = curr.right
      elsif curr.right.nil?
        @root = curr.left
      else
        # find the minimum node in right subtree
        node = copy_and_delete_min_in_right_subtree_of(curr)
        @root = node # replace deleted node with minimum node
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
        # find the minimum node in right subtree
        node = copy_and_delete_min_in_right_subtree_of(curr)
        parent.left = node # replace deleted node with minimum node
      end
    else
      if curr.left.nil? && curr.right.nil?
        parent.right = nil
      elsif curr.left.nil?
        parent.right = curr.right
      elsif curr.right.nil?
        parent.right = curr.left
      else
        # find the minimum node in right subtree
        node = copy_and_delete_min_in_right_subtree_of(curr)
        parent.right = node # replace deleted node with minimum node
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
      return curr if value == curr.data

      curr = (value < curr.data ? curr.left : curr.right)
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

  # calculates the number of levels beneath the given node
  def self.depth(node)
    return -1 if node.nil?

    # the depth is the max of the depths of the children plus 1
    [depth(node.left), depth(node.right)].max + 1
  end

  # returns whether the tree is balanced
  def balanced?
    # tree is balanced if the difference between left and right depths is within 1
    (Tree.depth(root.left) - Tree.depth(root.right)).abs <= 1
  end

  # rebalances the tree
  def rebalance!
    @root = build_tree(level_order)
  end

  private

  def copy_and_delete_min_in_right_subtree_of(curr)
    # find the minimum node in right subtree
    min_parent = curr # parent of minimum node
    min = curr.right # minimum node
    until min.left.nil? # find and set minimum node and parent
      min_parent = min
      min = min.left
    end
    node = Node.new(min.data) # create a copy node of min node
    node.left = curr.left
    node.right = curr.right
    # delete old minimum node location
    min_parent == curr ? node.right = min.right : min_parent.left = nil
    node
  end
end

array = Array.new(15) { rand(0..100) } # random array of numbers between 0 and 100
tree = Tree.new(array) # create tree using random array
puts tree.balanced?
p tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder
5.times { tree.insert(rand(101..110)) }
puts tree.balanced?
tree.rebalance!
puts tree.balanced?
p tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder
tree.delete(tree.root.data)
p tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder

