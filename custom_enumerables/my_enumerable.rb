#!/usr/bin/ruby
# frozen_string_literal: true

module Enumerable
  def my_each(&block)
    for item in self
      yield item
    end
  end

  def my_each_with_index

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
  else
    puts "my_#{method} unsupported"
    return
  end
  puts numbers.send("my_#{method}", &block)
  puts "---"
  puts numbers.send(method, &block)
end

if __FILE__ == $PROGRAM_NAME
  my_methods = %w[each each_with_index select all? any? none? count map inject]

  my_methods.each { |method| compare(method) }
end
