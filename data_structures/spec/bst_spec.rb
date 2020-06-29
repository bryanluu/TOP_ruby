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
      expect(node1 == node2).to eql(true)
    end
    it 'compares node with lesser node' do
      node1 = Node.new(6)
      node2 = Node.new(5)
      expect(node1 > node2).to eql(true)
    end
    it 'compares node with greater node' do
      node1 = Node.new(6)
      node2 = Node.new(7)
      expect(node1 < node2).to eql(true)
    end
  end
end