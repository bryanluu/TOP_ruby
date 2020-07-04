# frozen_string_literal: true
# spec/bst_spec.rb
require './lib/pieces'

describe Piece do
  describe '#initialize' do
    it 'stores the position' do
      board = Board.new
      pos = Array(2) { rand(0...Board.SIDE_LENGTH) }
      piece = Piece.new(board, pos)
      expect(piece.position).to eq(pos)
    end
    it 'activates the piece' do
      board = Board.new
      pos = Array(2) { rand(0...Board.SIDE_LENGTH) }
      piece = Piece.new(board, pos)
      expect(piece.active?).to be(true)
    end
  end
  describe '#move!' do
    it 'adjusts position' do
      board = Board.new
      pos = Array(2) { rand(0...Board.SIDE_LENGTH) }
      piece = Piece.new(board, pos)
      movement = Array(2) { rand(0...Board.SIDE_LENGTH) }
      dest = [pos.first + movement.first, pos.last + movement.last]
      expected = dest.first.between?(0, Board.SIDE_LENGTH-1) && dest.last.between?(0, Board.SIDE_LENGTH-1)
      expect(piece.move!(movement)).to be(expected)
    end
    it 'does nothing for invalid move' do
      board = Board.new
      pos = [0, 0]
      piece = Piece.new(board, pos)
      movement = [-1, -1]
      expect(piece.move!(movement)).to be(false)
    end
  end
  describe '#kill!' do
    it 'de-activates the piece' do
      board = Board.new
      piece = Piece.new(board, [0, 0])
      piece.kill!
      expect(piece.active?).to be(false)
    end
  end
end