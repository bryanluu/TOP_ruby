#!/usr/bin/ruby
# frozen_string_literal: true

module Enumerable
  def my_each
    for item in self
      yield item
    end
  end

  def my_each_with_index
    i = 0
    for item in self
      yield item, i
      i += 1
    end
  end

  def my_select
    result = self.class.new
    my_each do |item|
      if yield(item)
        result.push item
      end
    end
    result
  end

  def my_all?
    my_each do |item|
      return false unless yield(item)
    end
    true
  end

  def my_any?
    my_each do |item|
      return true if yield(item)
    end
    false
  end

  def my_none?
    my_each do |item|
      return false if yield(item)
    end
    true
  end

  def my_count
    c = 0
    my_each do |item|
      c += 1 if yield(item)
    end
    c
  end

  def my_map
    result = self.class.new
    my_each do |item|
      result.append yield(item)
    end
    result
  end

  def my_inject
    memo = nil
    my_each do |item|
      memo = (memo.nil? ? item : yield(memo, item))
    end
    memo
  end

end

def compare(method)
  puts "====="
  puts "my_#{method} vs. #{method}"
  numbers = (1..5).to_a
  block = nil
  case method
  when "each"
    block = Proc.new { |x| puts x }
  when "each_with_index"
    block = Proc.new { |x, i| puts "#{x}, #{i}" }
  when "select", "all?", "any?", "none?", "count", "map"
    block = Proc.new { |x| x % 2 == 0 }
  when "inject"
    block = Proc.new { |memo, item| memo * item }
  else
    puts "my_#{method} unsupported"
    return
  end
  result = numbers.send("my_#{method}", &block)
  puts "="
  puts result
  puts "---"
  result = numbers.send(method, &block)
  puts "="
  puts result
end

if __FILE__ == $PROGRAM_NAME
  my_methods = %w[each each_with_index select all? any? none? count map inject]

  my_methods.each { |method| compare(method) }
end
