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
    it 'correctly returns the Tile at the Chess coordinate' do
      board = Board.new
      expect(board['a1']).to be(board[7, 0])
    end
  end
  describe '#valid_position?' do
    it 'correctly returns true for a valid space on board' do
      position = Vector.new(Array.new(2) { rand(0...Board::SIDE_LENGTH) })
      expect(Board.valid_position?(position)).to be(true)
    end
    it 'correctly returns false for a space off the board' do
      expect(Board.valid_position?([-1, -1])).to be(false)
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
    it 'correctly moves a pawn when an en-passant capture is attempted' do
      board = Board.new
      board.move_piece!([1, 0], [3, 0]) # move pawn forward
      board.move_piece!([3, 0], [4, 0]) # move pawn forward
      board.move_piece!([6, 1], [4, 1]) # move enemy pawn forward
      # en-passant capture
      expect(board.move_piece!([4, 0], [5, 1]) && !board[4, 1].occupied?).to be(true)
    end
    it 'correctly returns false when an invalid en-passant capture is attempted' do
      board = Board.new
      board.move_piece!([1, 0], [3, 0]) # move pawn forward
      board.move_piece!([3, 0], [4, 0]) # move pawn forward
      board.move_piece!([6, 1], [4, 1]) # move enemy pawn forward
      board.move_piece!([6, 2], [4, 2]) # move enemy pawn forward
      # en-passant capture attempt
      expect(board.move_piece!([4, 0], [5, 1])).to be(false)
    end
    it 'correctly returns false when an invalid en-passant move is attempted' do
      board = Board.new
      board.move_piece!([1, 1], [3, 1]) # move pawn forward
      board.move_piece!([3, 1], [4, 1]) # move pawn forward
      board.move_piece!([6, 2], [4, 2]) # move enemy pawn forward
      # en-passant capture attempt
      expect(board.move_piece!([4, 1], [5, 0])).to be(false)
    end
  end
  describe '#location_vector' do
    it 'correctly converts Chess coord to location vector' do
      expect(Board.location_vector('a8').to_a).to eq([0, 0])
    end
    it 'correctly throws error for invalid coord' do
      puts Board::COLUMN_TO_INDEX[9]
      expect{Board.location_vector('a9')}.to raise_error(KeyError)
    end
  end
  describe '#king_is_dead?' do
    it 'correctly returns false for default start positions' do
      board = Board.new
      colors = %i[White Black].freeze
      expect(board.king_is_dead?(colors.sample)).to be(false)
    end
    it 'correctly returns true for a dead Black king' do
      board = Board.new
      board.move_piece!('a2', 'a4')
      board.move_piece!('a1', 'a3')
      board.move_piece!('a3', 'e3')
      board.move_piece!('e3', 'e7')
      board.move_piece!('e7', 'e8')
      expect(board.king_is_dead?(:Black)).to be(true)
    end
    it 'correctly returns true for a dead White king' do
      board = Board.new
      board.move_piece!('a7', 'a5')
      board.move_piece!('a8', 'a6')
      board.move_piece!('a6', 'e6')
      board.move_piece!('e6', 'e2')
      board.move_piece!('e2', 'e1')
      expect(board.king_is_dead?(:White)).to be(true)
    end
  end
end