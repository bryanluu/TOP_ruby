# frozen_string_literal: true

require 'pry'
require 'set'

# Hangman game class
class Game
  DICTIONARY = '../5desk.txt'

  def initialize
    @word = get_word_from_dictionary(DICTIONARY)
    @correct = Set.new
    @incorrect = Set.new
    @incorrect_guesses_allowed = 11
  end

  # private

  def win?
    @word.split('').to_set == @correct
  end

  def lose?
    @incorrect_guesses_allowed <= 0
  end

  def display_word
    letters = @word.split('')
    letters.each_with_index { |letter, i| letters[i] = '_' unless @correct.include? letter }
    letters.join('')
  end

  def guess_word(word)
    if word == @word
      @correct << word.split('')
    else
      @incorrect_guesses_allowed -= 1
    end
  end

  def guess_letter(letter)
    if @word.include? letter
      @correct << letter
    else
      @incorrect_guesses_allowed -= 1
      @incorrect << letter
    end
  end

  # gets a random (valid) word from the dictionary file
  def get_word_from_dictionary(filename)
    words = File.readlines(filename, chomp: true) # read in dictionary
    # get only valid length words
    valid_words = words.select do |word|
      word.length >= 5 && word.length <= 12
    end
    # choose a random valid_word
    valid_words.sample
  end
end

binding.pry