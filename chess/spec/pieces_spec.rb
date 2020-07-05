# frozen_string_literal: true
# spec/bst_spec.rb
require './lib/pieces'

describe Piece do
  describe '#initialize' do
    it 'stores the position' do
      board = Board.new
      pos = Vector.new(Array.new(2) { rand(0...Board::SIDE_LENGTH) })
      piece = Piece.new(board, pos)
      expect(piece.position).to eq(pos)
    end
    it 'activates the piece' do
      board = Board.new
      pos = Vector.new(Array.new(2) { rand(0...Board::SIDE_LENGTH) })
      piece = Piece.new(board, pos)
      expect(piece.active?).to be(true)
    end
  end
  describe '#move_to!' do
    it 'adjusts position' do
      board = Board.new
      pos = Vector.new(Array.new(2) { rand(0...Board::SIDE_LENGTH) })
      piece = Piece.new(board, pos)
      movement = Vector.new(Array.new(2) { rand(0...Board::SIDE_LENGTH) })
      dest = pos + movement
      valid = dest.to_a.first.between?(0, Board::SIDE_LENGTH-1) && dest.to_a.last.between?(0, Board::SIDE_LENGTH-1)
      success = piece.move_to!(dest)
      new_pos = piece.position
      expected_pos = (valid ? dest : pos)
      expect(success == valid && expected_pos == new_pos).to be(true)
    end
    it 'does nothing for invalid move' do
      board = Board.new
      pos = Vector.new([0, 0])
      piece = Piece.new(board, pos)
      dest = Vector.new([-1, -1])
      expect(piece.move_to!(dest)).to be(false)
    end
  end
  describe '#kill!' do
    it 'de-activates the piece' do
      board = Board.new
      piece = Piece.new(board, Vector.new([0, 0]))
      piece.kill!
      expect(piece.active?).to be(false)
    end
  end
end