# frozen_string_literal: true

require_relative 'pieces'
require 'pry'

# implements a Chess game
class Game
  def initialize
    @board = Board.new
    @turn = :White
  end

  def play
    play_round until @board.king_is_dead?(@turn)
    puts "#{Piece.opposite(@turn)} wins!"
  end

  private

  def play_round
    success = false
    until success
      puts "--- #{Piece::TEAM_ICONS[@turn]} turn ---"
      @board.display
      origin = prompt_origin
      correct_piece = @board[origin].occupied? && @board[origin].piece.color == @turn
      if correct_piece
        puts "#{@board[origin]} selected."
      else
        puts 'Invalid piece location selected!'
        next
      end
      destination = prompt_destination
      success = @board.move_piece!(origin, destination)
      puts 'Invalid move!' unless success
    end
    toggle_turn
  end

  def prompt_origin
    puts 'Enter piece location:'
    repeat = true
    while repeat
      begin
        origin = Board.location_vector(gets.chomp)
        repeat = false
      rescue KeyError => e
        repeat = true
      end
    end
    origin
  end

  def prompt_destination
    puts 'Enter destination:'
    repeat = true
    while repeat
      begin
        destination = Board.location_vector(gets.chomp)
        repeat = false
      rescue KeyError => e
        repeat = true
      end
    end
    destination
  end

  def toggle_turn
    @turn = Piece.opposite(@turn)
  end
end

# binding.pry
