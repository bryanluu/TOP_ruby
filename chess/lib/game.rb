# frozen_string_literal: true

require_relative 'pieces'

# implements a Chess game
class Game
  def initialize
    @board = Board.new
    @turn = :White
    @forfeit = false
    @cpu = prompt_cpu
  end

  def play
    play_round until game_over?
    @board.display
    puts "#{team_name(Piece.opposite(@turn))} wins!"
  end

  private

  def game_over?
    @forfeit || @board.king_is_dead?(@turn)
  end

  def play_round
    success = false
    display_state if @cpu[@turn]
    until success
      display_state unless @cpu[@turn]
      success = choose_random_move if @cpu[@turn]
      next if @cpu[@turn]

      origin = prompt_origin
      return if @forfeit

      correct_piece = @board[origin].occupied? && @board[origin].piece.color == @turn
      if correct_piece
        puts "#{@board[origin]} selected."
      else
        puts 'Invalid piece location selected!'
        next
      end
      destination = prompt_destination
      return if @forfeit

      success = @board.move_piece!(origin, destination)
      puts 'Invalid move!' unless success
    end
    puts 'Press [Enter] to continue...' if @cpu[@turn]
    gets if @cpu[@turn]
    toggle_turn
  end

  def display_state
    puts "------ #{team_name(@turn)} turn ------"
    @board.display
  end

  def team_name(color)
    "#{Piece::TEAM_ICONS[color]} " + (@cpu[color] ? '(CPU) ' : '')
  end

  def choose_random_move
    loc = @board.locations_of_pieces(@turn).sample # choose random piece
    origin = Board.location_vector(loc) # convert to location vector
    movement = @board[origin].piece.moves.sample # choose random move
    destination = origin + movement
    @board.move_piece!(origin, destination, true)
  end

  def prompt_cpu
    puts 'CPU player? (y/n)'
    cpu = { White: false, Black: false }
    if affirmative?
      puts 'Which team? (Black/White/both)'
      ans = gets.chomp
      ans == 'both' ? cpu.keys.each { |team| cpu[team] = true } : cpu[ans.to_sym] = true
    end
    cpu
  end

  def prompt_origin
    puts "Enter piece location (or '--save filename' to save the game, '--forfeit' to forfeit):"
    input = gets.chomp
    while save?(input)
      save(input)
      puts "Enter piece location (or '--save filename' to save the game, '--forfeit' to forfeit):"
      input = gets.chomp
    end
    return if forfeit?(input)

    repeat_until_success { Board.location_vector(input) }
  end

  def prompt_destination
    puts "Enter destination (or '--save filename' to save the game):"
    input = gets.chomp
    while save?(input)
      save(input)
      puts "Enter destination (or '--save filename' to save the game):"
      input = gets.chomp
    end
    return if forfeit?(input)

    repeat_until_success { Board.location_vector(input) }
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

  def save?(input)
    input.split.first == '--save'
  end

  def forfeit?(input)
    @forfeit = (input == '--forfeit')
  end

  def save(input)
    filename = input.split.last + '.save'
    if File.exist? filename
      puts "Overwrite #{filename}?"
      return unless affirmative?
    end
    File.open(filename, 'w') do |file|
      file.puts Marshal.dump(self) # save Game as binary string to filename
    end
    puts "Saved game to #{filename}."
  end
end

def affirmative?
  input = gets.chomp.downcase
  %w[y yes].include? input
end

puts 'Load game from file? (y/n)'
if affirmative?
  puts 'Enter name:'
  obj = File.read(gets.chomp + '.save')
  game = Marshal.load(obj)
else
  game = Game.new
end
game.play
