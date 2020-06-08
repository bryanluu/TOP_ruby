def count_occurences(string, substr)
    count = 0; i = -1;
    until i == nil do
        i = string.index(substr, i+1)
        if i
            count += 1
        end
    end
    return count
end

def substrings(string, dictionary)
    ans = {}
    dictionary.each do |word|
        count = count_occurences(string.downcase, word.downcase);
        if count > 0
            ans[word] = count
        end
    end
    return ans
end

### Main Code ###
dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]
puts substrings("below", dictionary)