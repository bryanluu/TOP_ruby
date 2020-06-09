def stock_picker(prices)
    min = prices.first; max = prices.last;
    min_index = 0; max_index = prices.length-1;

    # iterate over the prices
    prices.each_with_index do |p, i|
        if p > max && i > min_index
            max = p
            max_index = i
        end
        if p < min && i < max_index
            min = p
            min_index = i
        end
    end
    return [min_index, max_index]
end

### Main Code ###
puts "Enter prices (separated by spaces):"
prices = gets.chomp.split.map {|p| p.to_i}

puts stock_picker(prices)