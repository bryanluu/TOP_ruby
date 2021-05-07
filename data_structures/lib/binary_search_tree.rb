# frozen_string_literal: true

# Class that implements a Binary-Search-Tree (BST) Node
class Node
  include Comparable, Enumerable
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

  def initialize(array = [], show=false)
    @root = build_tree(array.sort.uniq)
    pretty_print if show
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  private

  # builds a balanced tree from array
  def build_tree(array)
    return nil if array.empty?

    mid = (array.length - 1) / 2
    node = Node.new(array[mid])
    node.left = build_tree(array[0...mid])
    node.right = build_tree(array[mid+1..-1])
    node
  end

  public

  # insert value into the tree and return root
  def insert(value, root = @root)
    node = Node.new(value)
    return (root == @root ? @root = node : node) if root.nil?

    return nil unless find(value).nil?

    if node < root
      root.left = insert(value, root.left)
    else
      root.right = insert(value, root.right)
    end
    root
  end

  # delete value from tree and return root
  def delete(value)
    return nil if root.nil?

    parent = nil
    curr = root
    until value == curr.data
      parent = curr
      curr = (value < curr.data ? curr.left : curr.right)
      return nil if curr.nil? # value not present in BST
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
  def find(value, root = @root)
    return nil if root.nil?
    return root if root.data == value

    value < root.data ? find(value, root.left) : find(value, root.right)
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
  def inorder(node = root, array = [], &block)
    return nil if node.nil?

    inorder(node.left, array, &block) unless node.left.nil?
    yield node if block_given?
    array << node
    inorder(node.right, array, &block) unless node.right.nil?
    array
  end

  # Yields nodes preorder of BST if block is given, returns as preorder array of nodes
  def preorder(node = root, array = [], &block)
    return nil if root.nil?

    yield node if block_given?
    array << node
    preorder(node.left, array, &block) unless node.left.nil?
    preorder(node.right, array, &block) unless node.right.nil?
    array
  end

  # Yields nodes postorder of BST if block is given, returns as postorder array of nodes
  def postorder(node = root, array = [], &block)
    return nil if root.nil?

    postorder(node.left, array, &block) unless node.left.nil?
    postorder(node.right, array, &block) unless node.right.nil?
    yield node if block_given?
    array << node
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
    @root = build_tree(inorder.map {|node| node.data})
  end

  # checks whether correct BST
  def correct?
    inorder.each_cons(2).all? { |p, n| p <= n }
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
tree = Tree.new(array, show=true) # create tree using random array
puts tree.balanced?
p tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder
5.times { tree.insert(rand(101..110)) }
puts tree.balanced?
tree.pretty_print
tree.rebalance!
puts tree.balanced?
tree.pretty_print
p tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder
tree.delete(tree.root.data)
p tree.level_order
p tree.preorder
p tree.postorder
p tree.inorder
puts "="*50
tree.pretty_print
puts tree.root.data