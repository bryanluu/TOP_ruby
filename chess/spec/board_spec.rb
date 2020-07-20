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
      expect(board.move_piece!([4, 1], [6, 3])).to be(true)
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
      expect(board.move_piece!([5, 0], [6, 1])).to be(true)
    end
    it 'correctly returns false when an invalid castling maneuver is attempted off-the-bat' do
      board = Board.new
      expect(board.move_piece!([0, 4], [0, 6])).to be(false)
    end
    it 'correctly returns false when an invalid castling maneuver after King is moved is attempted' do
      board = Board.new
      board.move_piece!([0, 6], [2, 7]) # move knight out of way
      board.move_piece!([1, 4], [3, 4]) # move pawn forward
      board.move_piece!([0, 5], [1, 4]) # move bishop out of way
      board.move_piece!([0, 4], [0, 5]) # move king
      board.move_piece!([0, 5], [0, 4]) # move king back
      expect(board.move_piece!([0, 4], [0, 6])).to be(false)
    end
    it 'correctly returns true when a legal castling maneuver is attempted' do
      board = Board.new
      board.move_piece!([0, 6], [2, 7]) # move knight out of way
      board.move_piece!([1, 4], [3, 4]) # move pawn forward
      board.move_piece!([0, 5], [1, 4]) # move bishop out of way
      expect(board.move_piece!([0, 4], [0, 6])).to be(true)
    end
    it 'correctly moves the (NE) King and Rook when a legal castling maneuver is attempted' do
      board = Board.new
      board.move_piece!([0, 6], [2, 7]) # move knight out of way
      board.move_piece!([1, 4], [3, 4]) # move pawn forward
      board.move_piece!([0, 5], [1, 4]) # move bishop out of way
      board.move_piece!([0, 4], [0, 6]) # castling maneuver
      expect(board[0, 6].piece.is_a?(King) && board[0, 5].piece.is_a?(Rook)).to be(true)
    end
    it 'correctly moves the (NW) King and Rook when a legal castling maneuver is attempted' do
      board = Board.new
      board.move_piece!([0, 1], [2, 0]) # move knight out of way
      board.move_piece!([1, 3], [3, 3]) # move pawn forward
      board.move_piece!([0, 2], [2, 4]) # move bishop out of way
      board.move_piece!([0, 3], [1, 3]) # move queen out of way
      board.move_piece!([0, 4], [0, 2]) # castling maneuver
      expect(board[0, 2].piece.is_a?(King) && board[0, 3].piece.is_a?(Rook)).to be(true)
    end
    it 'correctly moves the (SE) King and Rook when a legal castling maneuver is attempted' do
      board = Board.new
      board.move_piece!([7, 6], [5, 7]) # move knight out of way
      board.move_piece!([6, 4], [4, 4]) # move pawn forward
      board.move_piece!([7, 5], [6, 4]) # move bishop out of way
      board.move_piece!([7, 4], [7, 6]) # castling maneuver
      expect(board[7, 6].piece.is_a?(King) && board[7, 5].piece.is_a?(Rook)).to be(true)
    end
    it 'correctly moves the (SW) King and Rook when a legal castling maneuver is attempted' do
      board = Board.new
      board.move_piece!([7, 1], [5, 0]) # move knight out of way
      board.move_piece!([6, 3], [4, 3]) # move pawn forward
      board.move_piece!([7, 2], [5, 4]) # move bishop out of way
      board.move_piece!([7, 3], [6, 3]) # move queen out of way
      board.move_piece!([7, 4], [7, 2]) # castling maneuver
      expect(board[7, 2].piece.is_a?(King) && board[7, 3].piece.is_a?(Rook)).to be(true)
    end
  end
end