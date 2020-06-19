def get_word
    puts "Enter the string:"
    return gets.chomp
end

def get_shift
    puts "Enter the shift:"
    word = gets.chomp
    until string_is_integer? word do
        puts "Invalid input!"
        puts "Enter the shift as an integer:"
        word = gets.chomp
    end
    return word.to_i
end

def string_is_integer?(string)
    true if Integer(string) rescue false 
end

def char_is_upcase?(c)
    return c == c.upcase
end

def char_is_alpha?(c)
    return c.match(/^[a-zA-Z]$/)
end

def caesar_cipher(word, shift)
    lower = "abcdefghijklmnopqrstuvwxyz"
    upper = lower.upcase
    ord = {}
    upper.split("").each_with_index {|v, i| ord[v] = i}

    ans = ""

    word.split("").each do |c|
        if char_is_alpha? c
            if char_is_upcase? c 
                ans += upper[(ord[c] + shift) % upper.length]
            else
                ans += lower[(ord[c.upcase] + shift) % lower.length]
            end
        else
            ans += c
        end
    end

    return ans
end

#### Main Part of Code ####

word = get_word
shift = get_shift

puts caesar_cipher(word, shift)
