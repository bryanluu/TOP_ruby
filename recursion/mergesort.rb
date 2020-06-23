# sort array using mergesort algorithm
def mergesort(array)
  return array if array.length <= 1

  mid = array.length / 2
  left = mergesort(array[0...mid])
  right = mergesort(array[mid..-1])
  merge_and_sort!(left, right)
end

# merge left and right arrays together in sorted order
def merge_and_sort!(left, right)
  array = []
  left.first < right.first ? array.push(left.shift) : array.push(right.shift) until left.empty? || right.empty?
  right.empty? ? array.concat(left) : array.concat(right)
  array
end

puts 'Enter array of ints, separated by space:'
array = gets.chomp.split.map(&:to_i)
puts mergesort(array)