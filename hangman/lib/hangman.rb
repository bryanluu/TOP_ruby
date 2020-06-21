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
    @mistakes_left = 11
  end

  def play
    until game_over?
      puts display_word
      puts "Incorrect: #{@incorrect}" unless @incorrect.empty?
      puts "Mistakes remaining: #{@mistakes_left}"
      input_guess
    end
    puts lose? ? 'You lost...' : 'You win!'
    puts "The word was #{@word}"
  end

  private

  def input_guess
    guess = prompt_guess
    until new_guess? guess
      puts 'Already guessed that!'
      guess = prompt_guess
    end
    if guess.length == 1
      guess_letter(guess)
    else
      guess_word(guess)
    end
  end

  def prompt_guess
    puts 'Guess a letter or word:'
    gets.chomp.downcase
  end

  def new_guess?(guess)
    return true unless @correct.include?(guess) || @incorrect.include?(guess)

    false
  end

  def game_over?
    win? || lose?
  end

  def win?
    @word.split('').to_set == @correct
  end

  def lose?
    @mistakes_left <= 0
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
      @mistakes_left -= 1
      @incorrect << word
    end
  end

  def guess_letter(letter)
    if @word.include? letter
      @correct << letter
    else
      @mistakes_left -= 1
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

g = Game.new
g.play
