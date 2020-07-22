# frozen_string_literal: true

class Vector
  def initialize(array)
    @data = array[0..-1]
  end

  def [](*args)
    @data.[](*args)
  end

  def ==(other)
    @data == other.to_a
  end

  def +(other)
    raise TypeError, 'Uneven length vectors added!' unless ndim == other.ndim

    result = Array.new(ndim) { |i| @data[i] + other[i] }
    Vector.new(result)
  end

  def -(other)
    raise TypeError, 'Uneven length vectors added!' unless ndim == other.ndim

    result = Array.new(ndim) { |i| @data[i] - other[i] }
    Vector.new(result)
  end

  def *(other)
    raise TypeError, 'Must be multiplied by a scalar (number)!' unless other.is_a?(Numeric)

    result = Array.new(ndim) { |i| @data[i] * other }
    Vector.new(result)
  end

  def /(other)
    raise TypeError, 'Must be divided by a scalar (number)!' unless other.is_a?(Numeric)

    result = Array.new(ndim) { |i| @data[i] / other }
    Vector.new(result)
  end

  def ndim
    @data.length
  end

  def to_s
    @data.inspect
  end

  def to_a
    @data[0..-1]
  end

  def copy
    Vector.new(@data)
  end

  def inspect
    "\#<#{ndim}-dim. Vector: " + @data.inspect + '>'
  end

  def self.zero
    Vector.new([0, 0])
  end
end