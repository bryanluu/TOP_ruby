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
  when "select"
    block = Proc.new { |x| x % 2 == 0 }
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
