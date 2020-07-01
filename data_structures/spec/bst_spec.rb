# frozen_string_literal: true
# spec/bst_spec.rb
require './lib/binary_search_tree'

describe Node do
  describe '#initialize' do
    it 'creates a BST node with the given value' do
      data = 6
      node = Node.new(data)
      expect(node.data).to eql(data)
    end
  end
  describe '#<=>' do
    it 'compares node with another that equals it' do
      data = 5
      node1 = Node.new(data)
      node2 = Node.new(data)
      expect(node1).to eq(node2)
    end
    it 'compares node with lesser node' do
      node1 = Node.new(6)
      node2 = Node.new(5)
      expect(node1).to be > node2
    end
    it 'compares node with greater node' do
      node1 = Node.new(6)
      node2 = Node.new(7)
      expect(node1).to be < node2
    end
  end
end

describe Tree do
  describe '#initialize' do
    it 'creates a BST from array correctly' do
      array = Array(1..3).shuffle
      tree = Tree.new(array)
      expect(tree.root.data == 2 && \
            tree.root.left.data == 1 && \
            tree.root.right.data == 3).to eql(true)
    end
    it 'creates an empty BST' do
      tree = Tree.new
      expect(tree.root).to be(nil)
    end
    it 'creates balanced BST' do
      array = (Array.new(100) { rand(0..100) })
      tree = Tree.new(array)
      expect(tree.balanced?).to be(true)
    end
  end
  describe '#insert' do
    it 'creates a root from empty tree' do
      value = rand(0..100)
      tree = Tree.new
      tree.insert(value)
      expect(tree.root.data).to be(value)
    end
    it 'returns node if empty child passed' do
      value = 0
      tree = Tree.new([1])
      expect(tree.insert(value, tree.root.left).data).to be(value)
    end
    it 'adds a value smaller than root as the left child' do
      value = rand(0..10)
      tree = Tree.new([20])
      tree.insert(value)
      expect(tree.root.left.data).to be(value)
    end
    it 'adds a value larger than root as the right child' do
      value = rand(30..40)
      tree = Tree.new([20])
      tree.insert(value)
      expect(tree.root.right.data).to be(value)
    end
    it 'adds a value to the subtree correctly' do
      value = 6
      tree = Tree.new([1, 2, 3])
      tree.insert(value)
      expect(tree.root.right.right.data).to be(value)
    end
  end
  describe '#delete' do
    it 'deletes the root correctly' do
      tree = Tree.new([1, 2, 3])
      tree.delete(2)
      expect(tree.root.data).not_to be(2)
    end
    it 'deletes left child correctly' do
      tree = Tree.new([1, 2, 3])
      left = tree.root.left
      expect(tree.delete(1).left).not_to be(left)
    end
    it 'deletes right child correctly' do
      tree = Tree.new([1, 2, 3])
      right = tree.root.right
      expect(tree.delete(3).right).not_to be(right)
    end
    it 'deletes value from large tree correctly' do
      array = Array.new(100) { rand(0..100) }
      tree = Tree.new(array)
      value = array.sample
      tree.delete(value)
      expect(tree.find(value)).to be(nil)
    end
    it 'does nothing on empty tree' do
      tree = Tree.new
      expect(tree.delete(5)).to be(nil)
    end
    it 'returns nil if value not present' do
      tree = Tree.new([1, 2, 3])
      expect(tree.delete(4)).to be(nil)
    end
  end
  describe '#find' do
    it 'returns node in tree' do
      array = Array.new(100) { rand(0..100) }
      tree = Tree.new(array)
      value = array.sample
      expect(tree.find(value).data).to be(value)
    end
    it 'returns nil if not found in tree' do
      array = Array.new(100) { rand(0..100) }
      tree = Tree.new(array)
      value = 101
      expect(tree.find(value)).to be(nil)
    end
  end
  describe '#level_order' do
    it 'correctly gives level order array' do
      tree = Tree.new(Array(1..7))
      expect(tree.level_order.map(&:data)).to eq([4, 2, 6, 1, 3, 5, 7])
    end
    it 'can be run as a block correctly' do
      tree = Tree.new(Array(1..7))
      array = []
      tree.level_order do |node|
        array << node.data
      end
      expect(array).to eq([4, 2, 6, 1, 3, 5, 7])
    end
  end
  describe '#inorder' do
    it 'correctly gives inorder array' do
      tree = Tree.new(Array(1..7))
      expect(tree.inorder.map(&:data)).to eq([1, 2, 3, 4, 5, 6, 7])
    end
    it 'can be run as a block correctly' do
      tree = Tree.new(Array(1..7))
      array = []
      tree.inorder do |node|
        array << node.data
      end
      expect(array).to eq([1, 2, 3, 4, 5, 6, 7])
    end
  end
  describe '#preorder' do
    it 'correctly gives preorder array' do
      tree = Tree.new(Array(1..7))
      expect(tree.preorder.map(&:data)).to eq([4, 2, 1, 3, 6, 5, 7])
    end
    it 'can be run as a block correctly' do
      tree = Tree.new(Array(1..7))
      array = []
      tree.preorder do |node|
        array << node.data
      end
      expect(array).to eq([4, 2, 1, 3, 6, 5, 7])
    end
  end
  describe '#postorder' do
    it 'correctly gives postorder array' do
      tree = Tree.new(Array(1..7))
      expect(tree.postorder.map(&:data)).to eq([1, 3, 2, 5, 7, 6, 4])
    end
    it 'can be run as a block correctly' do
      tree = Tree.new(Array(1..7))
      array = []
      tree.postorder do |node|
        array << node.data
      end
      expect(array).to eq([1, 3, 2, 5, 7, 6, 4])
    end
  end
  describe '#depth' do
    it 'returns -1 for an empty tree' do
      tree = Tree.new
      expect(Tree.depth(tree.root)).to be(-1)
    end
    it 'returns correct depth of 0 for single node tree' do
      tree = Tree.new([0])
      expect(Tree.depth(tree.root)).to be(0)
    end
    it 'returns correct depth for larger tree' do
      tree = Tree.new(Array(1..7))
      expect(Tree.depth(tree.root)).to be(2)
    end
  end
  describe '#balanced?' do
    it 'returns false for left-unbalanced tree' do
      tree = Tree.new([5])
      tree.insert(0)
      tree.insert(1)
      expect(tree.balanced?).to be(false)
    end
    it 'returns false for right-unbalanced tree' do
      tree = Tree.new([5])
      tree.insert(10)
      tree.insert(11)
      expect(tree.balanced?).to be(false)
    end
    it 'returns true for simple balanced tree' do
      tree = Tree.new([5])
      tree.insert(0)
      tree.insert(10)
      expect(tree.balanced?).to be(true)
    end
  end
  describe '#rebalance!' do
    it 'rebalances left-unbalanced tree' do
      tree = Tree.new([5])
      tree.insert(0)
      tree.insert(1)
      tree.rebalance!
      expect(tree.balanced?).to be(true)
    end
    it 'rebalances right-unbalanced tree' do
      tree = Tree.new([5])
      tree.insert(10)
      tree.insert(11)
      tree.rebalance!
      expect(tree.balanced?).to be(true)
    end
  end
end
