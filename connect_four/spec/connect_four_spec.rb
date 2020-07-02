# frozen_string_literal: true
# spec/bst_spec.rb
require './lib/connect_four'

describe Cage do
  describe '#initialize' do
    it 'creates an empty array for the cage' do
      cage = Cage.new
      expected_array = Array.new(6) { Array.new(7) { Cage.empty_symbol } }
      expect(cage.array).to eq(expected_array)
    end
  end
  describe '#to_s' do
    it 'creates a string for the cage' do
      cage = Cage.new
      rows = []
      cage.array.each do |row|
        rows << row.join
      end
      expected_str = rows.join("\n")
      expect(cage.to_s).to eq(expected_str)
    end
  end
  describe '#drop!' do
    it 'drops a red token first in the corresponding column' do
      cage = Cage.new
      column = rand(0...7)
      cage.drop!(column)
      expect(cage.array[5][column]).to eq(Cage.red_token)
    end
    it 'drops and returns true when successful' do
      cage = Cage.new
      column = rand(0...7)
      expect(cage.drop!(column)).to be(true)
    end
    it 'drops a yellow token after dropping red token' do
      cage = Cage.new
      column = rand(0...7)
      cage.drop!(column)
      cage.drop!(column)
      expect(cage.array[5][column] == Cage.red_token && cage.array[4][column] == Cage.yellow_token).to be(true)
    end
    it 'returns false when column is full' do
      cage = Cage.new
      column = rand(0...7)
      6.times { cage.drop!(column) }
      expect(cage.drop!(column)).to be(false)
    end
  end
  describe '#column_full?' do
    it 'correctly returns true when full' do
      cage = Cage.new
      column = rand(0...7)
      6.times { cage.drop!(column) }
      expect(cage.column_full?(column)).to be(true)
    end
    it 'correctly returns false when only one token is dropped' do
      cage = Cage.new
      column = rand(0...7)
      cage.drop!(column)
      expect(cage.column_full?(column)).to be(false)
    end
    it 'correctly returns false when empty' do
      cage = Cage.new
      column = rand(0...7)
      expect(cage.column_full?(column)).to be(false)
    end
  end
  describe '#empty?' do
    it 'correctly returns true when empty' do
      cage = Cage.new
      expect(cage.empty?).to be(true)
    end
    it 'correctly returns false once a token is dropped' do
      cage = Cage.new
      column = rand(0...7)
      cage.drop!(column)
      expect(cage.empty?).to be(false)
    end
    it 'correctly returns true after a reset' do
      cage = Cage.new
      column = rand(0...7)
      cage.drop!(column)
      cage.reset!
      expect(cage.empty?).to be(true)
    end
  end
  describe '#connects_four?' do
    it 'correctly returns false' do
      cage = Cage.new
      expect(cage.connects_four?).to be(false)
    end
    it 'correctly returns true for horizontal case' do
      cage = Cage.new
      0.upto(3) do |i|
        cage.drop!(i) # drop white token
        cage.drop!(i) # drop black token
      end
      expect(cage.connects_four?).to be(true)
    end
    it 'correctly returns true for vertical case' do
      cage = Cage.new
      column = rand(0...6)
      4.times do
        cage.drop!(column)
        cage.drop!(column + 1)
      end
      expect(cage.connects_four?).to be(true)
    end
    it 'correctly returns true for diagonal case' do
      cage = Cage.new
      cage.drop!(0) # white
      cage.drop!(1) # black
      cage.drop!(1) # white
      cage.drop!(2) # black
      cage.drop!(2) # white
      cage.drop!(0) # black
      cage.drop!(2) # white
      cage.drop!(3) # black
      cage.drop!(3) # white
      cage.drop!(3) # black
      cage.drop!(3) # white
      expect(cage.connects_four?).to be(true)
    end
    it 'correctly returns true for antidiagonal case' do
      cage = Cage.new
      cage.drop!(3) # white
      cage.drop!(2) # black
      cage.drop!(2) # white
      cage.drop!(1) # black
      cage.drop!(1) # white
      cage.drop!(3) # black
      cage.drop!(1) # white
      cage.drop!(0) # black
      cage.drop!(0) # white
      cage.drop!(0) # black
      cage.drop!(0) # white
      expect(cage.connects_four?).to be(true)
    end
  end
end