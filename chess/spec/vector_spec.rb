# frozen_string_literal: true
# spec/bst_spec.rb
require './lib/vector'

describe Vector do
  describe '#initialize' do
    it 'creates a vector from array' do
      dim = rand(1..5)
      array = Array.new(dim) { rand(0..10) }
      v = Vector.new(array)
      expect(v.to_a).to eq(array)
    end
  end
  describe '#[]' do
    it 'correctly indices into data array' do
      dim = rand(2..5)
      array = Array.new(dim) { rand(0..10) }
      v = Vector.new(array)
      i = rand(0...dim)
      expect(v[i]).to be(array[i])
    end
  end
  describe '#==' do
    it 'correctly returns true' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      v = Vector.new(a)
      expect(u).to eq(v)
    end
    it 'correctly returns false' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      a[0] = -1
      v = Vector.new(a)
      expect(u).not_to eq(v)
    end
  end
  describe '#+' do
    it 'adds two same-size vectors correctly' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      b = Array.new(dim) { rand(0..10) }
      v = Vector.new(b)
      c = Array.new(dim) { |i| a[i] + b[i] }
      w = Vector.new(c)
      expect(u + v).to eq(w)
    end
    it 'complains when incompatible vectors are added' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      b = Array.new(dim) { 'abcdefghijklmnopqrstuvwxyz'.split('').sample }
      v = Vector.new(b)
      expect{ u + v }.to raise_error(TypeError)
    end
    it 'complains when uneven vectors are added' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      b = Array.new(dim + 1) { rand(0..10) }
      v = Vector.new(b)
      expect{ u + v }.to raise_error(TypeError)
    end
  end
  describe '#-' do
    it 'subtracts two same-size vectors correctly' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      b = Array.new(dim) { rand(0..10) }
      v = Vector.new(b)
      c = Array.new(dim) { |i| a[i] - b[i] }
      w = Vector.new(c)
      expect(u - v).to eq(w)
    end
    it 'complains when incompatible vectors are subtracted' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      b = Array.new(dim) { 'abcdefghijklmnopqrstuvwxyz'.split('').sample }
      v = Vector.new(b)
      expect{ u - v }.to raise_error(TypeError)
    end
    it 'complains when uneven vectors are subtracted' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      u = Vector.new(a)
      b = Array.new(dim + 1) { rand(0..10) }
      v = Vector.new(b)
      expect{ u - v }.to raise_error(TypeError)
    end
  end
  describe '#ndim' do
    it 'correctly returns length of data array' do
      dim = rand(1..5)
      a = Array.new(dim) { rand(0..10) }
      v = Vector.new(a)
      expect(v.ndim).to be(dim)
    end
  end
  describe '#to_s' do
    it 'creates an array string' do
      dim = rand(1..5)
      array = Array.new(dim) { rand(0..10) }
      v = Vector.new(array)
      str = array.inspect
      expect(v.to_s).to eq(str)
    end
  end
  describe '#inspect' do
    it 'creates a string representation' do
      dim = rand(1..5)
      array = Array.new(dim) { rand(0..10) }
      v = Vector.new(array)
      str = "\#<#{array.length}-dim. Vector: " + array.inspect + '>'
      expect(v.inspect).to eq(str)
    end
  end
  describe '#to_a' do
    it 'returns a copy of the vector array' do
      v = Vector.new([1, 2])
      expect(v.to_a).to eq([1, 2])
    end
  end
end