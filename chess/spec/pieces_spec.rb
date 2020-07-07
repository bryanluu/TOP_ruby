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

describe 'Queen' do
  describe '#valid_move?' do
    it 'returns true correctly for horizontal motion' do
      board = Board.new
      queen = Queen.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([0, step]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for vertical motion' do
      board = Board.new
      queen = Queen.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, 0]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for diagonal motion' do
      board = Board.new
      queen = Queen.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, step]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for antidiagonal motion' do
      board = Board.new
      queen = Queen.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, -step]) } # creates the move vectors
      expect(moves.all? { |move| queen.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      board = Board.new
      queen = Queen.new(board, Vector.new([0, 0]), :White)
      expect(queen.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      board = Board.new
      queen = Queen.new(board, Vector.new([0, 0]), :White)
      expect(queen.valid_move?(Vector.new([2, 1]))).to be(false)
    end
  end
end

describe 'Rook' do
  describe '#valid_move?' do
    it 'returns true correctly for horizontal motion' do
      board = Board.new
      rook = Rook.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([0, step]) } # creates the move vectors
      expect(moves.all? { |move| rook.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for vertical motion' do
      board = Board.new
      rook = Rook.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, 0]) } # creates the move vectors
      expect(moves.all? { |move| rook.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      board = Board.new
      rook = Rook.new(board, Vector.new([0, 0]), :White)
      expect(rook.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      board = Board.new
      rook = Rook.new(board, Vector.new([0, 0]), :White)
      expect(rook.valid_move?(Vector.new([1, 1]))).to be(false)
    end
  end
end

describe 'Bishop' do
  describe '#valid_move?' do
    it 'returns true correctly for diagonal motion' do
      board = Board.new
      bishop = Bishop.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, step]) } # creates the move vectors
      expect(moves.all? { |move| bishop.valid_move?(move) }).to be(true)
    end
    it 'returns true correctly for antidiagonal motion' do
      board = Board.new
      bishop = Bishop.new(board, Vector.new([0, 0]), :White)
      moves = Array(1...Board::SIDE_LENGTH) # the range of horizontal motion
      moves.map! { |step| Vector.new([step, -step]) } # creates the move vectors
      expect(moves.all? { |move| bishop.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      board = Board.new
      bishop = Bishop.new(board, Vector.new([0, 0]), :White)
      expect(bishop.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      board = Board.new
      bishop = Bishop.new(board, Vector.new([0, 0]), :White)
      expect(bishop.valid_move?(Vector.new([1, 0]))).to be(false)
    end
  end
end

describe 'Knight' do
  describe '#valid_move?' do
    it 'returns true correctly for L motion' do
      board = Board.new
      knight = Knight.new(board, Vector.new([0, 0]), :White)
      moves = [1, -1].product([2, -2])
      moves += moves.map(&:reverse) # creates the L-moveset
      expect(moves.all? { |move| knight.valid_move?(move) }).to be(true)
    end
    it 'returns false correctly for no motion' do
      board = Board.new
      knight = Knight.new(board, Vector.new([0, 0]), :White)
      expect(knight.valid_move?(Vector.zero)).to be(false)
    end
    it 'returns false correctly for invalid motion' do
      board = Board.new
      knight = Knight.new(board, Vector.new([0, 0]), :White)
      expect(knight.valid_move?(Vector.new([1, 1]))).to be(false)
    end
  end
end

describe 'Pawn' do
  describe '#valid_move?' do
    it 'returns true correctly for single step' do
      board = Board.new
      pawn = Pawn.new(board, Vector.new([7, 0]), :White)
      expect(pawn.move_to!(Vector.new([6, 0]))).to be(true)
    end
    it 'returns true correctly for initial double step' do
      board = Board.new
      pawn = Pawn.new(board, Vector.new([7, 0]), :White)
      expect(pawn.move_to!(Vector.new([5, 0]))).to be(true)
    end
    it 'returns false correctly for double step after single step' do
      board = Board.new
      pawn = Pawn.new(board, Vector.new([7, 0]), :White)
      pawn.move_to!(Vector.new([6, 0]))
      expect(pawn.move_to!(Vector.new([4, 0]))).to be(false)
    end
    it 'returns false correctly for invalid step' do
      board = Board.new
      pawn = Pawn.new(board, Vector.new([0, 0]), :Black)
      expect(pawn.move_to!(Vector.new([5, 5]))).to be(false)
    end
  end
end