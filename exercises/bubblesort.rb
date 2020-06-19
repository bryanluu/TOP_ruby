def bubble_sort(array)
    result = array[0..-1]  # copy array
    e = array.length
    until e == 1 do
        for i in 0..e-2
            if result[i] > result[i+1]
                swap!(result, i, i+1)
            end
        end
        e -= 1
    end
    return result
end

def swap!(array, i, j)
    tmp = array[j]
    array[j] = array[i]
    array[i] = tmp
end

### Main Code ###
puts "Enter numbers, separated by spaces:"
array = gets.chomp.split.map {|x| x.to_i }

puts "Pre-sorted Array:"
p array

result = bubble_sort(array)

puts "Sorted Array:"
p result