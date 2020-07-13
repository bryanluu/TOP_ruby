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
      pos = Vector.new([3, 3])
      dest = Vector.new([4, 3])
      expect(board.move_piece!(pos, dest)).to be(false)
    end
    it 'correctly returns false for moving to an off-board spot' do
      board = Board.new
      pos = Vector.zero
      dest = Vector.new([-1, -1])
      expect(board.move_piece!(pos, dest)).to be(false)
    end
    it 'correctly returns true for moving to an empty spot' do
      board = Board.new
      pos = Vector.new([1, 0])
      dest = Vector.new([2, 0])
      expect(board.move_piece!(pos, dest)).to be(true)
    end
  end
end