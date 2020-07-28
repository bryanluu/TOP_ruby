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
    puts "#{Piece::TEAM_ICONS[Piece.opposite(@turn)]} wins!"
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
    repeat_until_success { Board.location_vector(gets.chomp) }
  end

  def prompt_destination
    puts 'Enter destination:'
    repeat_until_success { Board.location_vector(gets.chomp) }
  end

  # repeat block until success
  def repeat_until_success
    repeat = true
    while repeat
      begin
        result = yield
        repeat = false
      rescue StandardError
        repeat = true
      end
    end
    result
  end

  def toggle_turn
    @turn = Piece.opposite(@turn)
  end
end

binding.pry
