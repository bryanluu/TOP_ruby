# frozen_string_literal: true
# spec/bst_spec.rb
require './lib/board'

describe Board do
  describe '#[]' do
    it 'correctly returns the Tile at the given row and col' do
      board = Board.new
      expect(board[0, 0].piece.symbol).to eq("\u265C")
    end
    it 'correctly returns the Tile at the position vector' do
      board = Board.new
      expect(board[Vector.zero].piece.symbol).to eq("\u265C")
    end
  end
  describe '#valid_position?' do
    it 'correctly returns true for a valid space on board' do
      board = Board.new
      position = Vector.new(Array.new(2) { rand(0...Board::SIDE_LENGTH) })
      expect(board.valid_position?(position)).to be(true)
    end
    it 'correctly returns false for a space off the board' do
      board = Board.new
      expect(board.valid_position?([-1, -1])).to be(false)
    end
  end
  describe '#move_piece!' do
    it 'correctly returns false for moving an empty spot' do
      board = Board.new
      pos = Vector.new([3, 3]) # empty spot
      dest = Vector.new([4, 3]) # empty spot
      expect(board.move_piece!(pos, dest)).to be(false)
    end
    it 'correctly returns false for moving to an off-board spot' do
      board = Board.new
      pos = Vector.zero # Rook location
      dest = Vector.new([-1, -1]) # off-board
      expect(board.move_piece!(pos, dest)).to be(false)
    end
    it 'correctly returns true for moving to an empty spot' do
      board = Board.new
      pos = Vector.new([1, 0]) # Pawn location
      dest = Vector.new([2, 0]) # Empty spot
      expect(board.move_piece!(pos, dest)).to be(true)
    end
    it 'correctly returns false for moving a Rook to an empty spot blocked by another piece' do
      board = Board.new
      pos = Vector.zero # Rook location
      dest = Vector.new([4, 0]) # Empty spot
      expect(board.move_piece!(pos, dest)).to be(false)
    end
    it 'correctly returns true for moving a Knight to an empty spot blocked by another piece' do
      board = Board.new
      pos = Vector.new([0, 1]) # Knight location
      dest = Vector.new([2, 0]) # Empty spot
      expect(board.move_piece!(pos, dest)).to be(true)
    end
    it 'correctly returns the pawn after moving a Bishop to an enemy pawn' do
      board = Board.new
      board.move_piece!([1, 4], [2, 4]) # move pawn out of the way
      board.move_piece!([0, 5], [4, 1]) # move bishop to the middle-field
      pawn = board[6, 3].piece # the target pawn
      expect(board.move_piece!([4, 1], [6, 3])).to be(pawn)
    end
    it 'correctly returns false for a Pawn trying to eat an enemy in front' do
      board = Board.new
      board.move_piece!([1, 0], [3, 0]) # move pawn forward
      board.move_piece!([3, 0], [4, 0])
      board.move_piece!([4, 0], [5, 0])
      expect(board.move_piece!([5, 0], [6, 0])).to be(false)
    end
    it 'correctly returns the enemy Pawn for a Pawn trying to eat an enemy diagonally' do
      board = Board.new
      board.move_piece!([1, 0], [3, 0]) # move pawn forward
      board.move_piece!([3, 0], [4, 0])
      board.move_piece!([4, 0], [5, 0])
      pawn = board[6, 1].piece
      expect(board.move_piece!([5, 0], [6, 1])).to be(pawn)
    end
  end
end