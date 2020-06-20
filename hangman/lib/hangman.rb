# gets a random (valid) word from the dictionary file
def get_word_from_dictionary(filename)
  words = File.readlines(filename) # read in dictionary
  # get only valid length words
  valid_words = words.select do |word|
    word.length >= 5 && word.length <= 12
  end
  # choose a random valid_word
  valid_words.sample
end

puts get_word_from_dictionary('../5desk.txt')