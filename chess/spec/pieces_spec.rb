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

describe 'King' do
  describe '#valid_move?' do
    it 'returns true for single step' do
      board = Board.new
      king = King.new(board, Vector.new([1, 1]), :White)
      steps = [-1, 0, 1]
      moves = steps.product(steps) # the single steps around current position
      moves.delete([0, 0]) # delete current position
      moves.map! { |move| Vector.new(move) } # convert moves into Vectors
      expect(moves.all? { |move| king.valid_move?(move) }).to be(true)
    end
    it 'returns false for invalid step' do
      board = Board.new
      king = King.new(board, Vector.new([0, 0]), :White)
      expect(king.valid_move?(Vector.new([2, 2]))).to be(false)
    end
  end
end