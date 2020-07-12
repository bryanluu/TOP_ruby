# frozen_string_literal: true
# spec/bst_spec.rb
require './lib/pieces'

describe Piece do
  describe '#initialize' do
    it 'activates the piece' do
      piece = Piece.new
      expect(piece.active?).to be(true)
    end
  end
  describe '#kill!' do
    it 'de-activates the piece' do
      piece = Piece.new
      piece.kill!
      expect(piece.active?).to be(false)
    end
  end
end

describe 'King' do
  describe '#valid_move?' do
    it 'returns true for single step' do
      king = King.new(:White)
      steps = [-1, 0, 1]
      moves = steps.product(steps) # the single steps around current position
      moves.delete([0, 0]) # delete current position
      moves.map! { |move| Vector.new(move) } # convert moves into Vectors
      expect(moves.all? { |move| king.valid_move?(move) }).to be(true)
    end
    it 'returns false for invalid step' do
      king = King.new(:White)
      expect(king.valid_move?(Vector.new([2, 2]))).to be(false)
    end
  end
end

describe 'Queen' do
  describe '#valid_move?' do
    it 'returns true correctly for horizontal motion' do
      queen = Queen.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([0, step]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for vertical motion' do
      queen = Queen.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, 0]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for diagonal motion' do
      queen = Queen.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, step]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for antidiagonal motion' do
      queen = Queen.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, -step]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      queen = Queen.new(:White)
      expect(queen.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      queen = Queen.new(:White)
      expect(queen.valid_move?(Vector.new([2, 1]))).to be(false)
    end
  end
end

describe 'Rook' do
  describe '#valid_move?' do
    it 'returns true correctly for horizontal motion' do
      rook = Rook.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([0, step]) } # creates the move vectors
      expect(moves.all? { |move| rook.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for vertical motion' do
      rook = Rook.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, 0]) } # creates the move vectors
      expect(moves.all? { |move| rook.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      rook = Rook.new(:White)
      expect(rook.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      rook = Rook.new(:White)
      expect(rook.valid_move?(Vector.new([1, 1]))).to be(false)
    end
  end
end

describe 'Bishop' do
  describe '#valid_move?' do
    it 'returns true correctly for diagonal motion' do
      bishop = Bishop.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, step]) } # creates the move vectors
      expect(moves.all? { |move| bishop.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for antidiagonal motion' do
      bishop = Bishop.new(:White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, -step]) } # creates the move vectors
      expect(moves.all? { |move| bishop.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      bishop = Bishop.new(:White)
      expect(bishop.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      bishop = Bishop.new(:White)
      expect(bishop.valid_move?(Vector.new([1, 0]))).to be(false)
    end
  end
end

describe 'Knight' do
  describe '#valid_move?' do
    it 'returns true correctly for L motion' do
      knight = Knight.new(:White)
      moves = [1, -1].product([2, -2])
      moves += moves.map(&:reverse) # creates the L-moveset
      expect(moves.all? { |move| knight.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      knight = Knight.new(:White)
      expect(knight.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      knight = Knight.new(:White)
      expect(knight.valid_move?(Vector.new([1, 1]))).to be(false)
    end
  end
end

describe 'Pawn' do
  describe '#valid_move?' do
    it 'returns true correctly for single step' do
      pawn = Pawn.new(:White)
      expect(pawn.valid_move?(Vector.new([-1, 0]))).to be(true)
    end
    it 'returns true correctly for initial double step' do
      pawn = Pawn.new(:White)
      expect(pawn.valid_move?(Vector.new([-2, 0]))).to be(true)
    end
    it 'returns false correctly for double step after single step' do
      pawn = Pawn.new(:White)
      pawn.move!
      expect(pawn.valid_move?(Vector.new([-2, 0]))).to be(false)
    end
    it 'returns false correctly for invalid step' do
      pawn = Pawn.new(:Black)
      expect(pawn.valid_move?(Vector.new([2, 1]))).to be(false)
    end
    it 'returns false correctly for no movement' do
      pawn = Pawn.new(:Black)
      expect(pawn.valid_move?(Vector.zero)).to be(false)
    end
  end
end