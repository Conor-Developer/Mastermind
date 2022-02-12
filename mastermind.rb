# frozen_string_literal: true

require 'pry'

# Module for creating pegs with numbers and background colours
module Pegs
  def self.map_colours_numbers(number)
    case number
    when 1
      colour_number(:one, 1)
    when 2
      colour_number(:two, 2)
    when 3
      colour_number(:three, 3)
    when 4
      colour_number(:four, 4)
    when 5
      colour_number(:five, 5)
    when 6
      colour_number(:six, 6)
    end
  end

  def self.colour_number(colour, number)
    bg_colour_map = {
      one: 41,
      two: 44,
      three: 42,
      four: 45,
      five: 43,
      six: 46
    }

    "\e[#{bg_colour_map[colour]}m\e[30m  #{number}  \e[0m"
  end

  def self.correct_clue
    "\e[31m●\e[0m"
  end

  def self.partially_correct_clue
    "\e[37m●\e[0m"
  end
end

# The foundations of the Mastermind Game
class Game
  attr_accessor :pool_clues, :correct_clue_pool, :partially_correct_clue_pool

  include Pegs

  def initialize
    @player_guess_array = []
    @partially_correct_clue = '●'
    @correct_clue = '●'
    @colours = [1, 2, 3, 4, 5, 6]
    @random_colour_selection = []
    @game_rounds = 12
    @continue_game = true
    @correct_clue_pool = []
    @partially_correct_clue_pool = []
  end

  private

  def declare_winner(player_guess_array)
    return unless player_guess_array[0] == '0'

    winner = player_guess_array.all? do |element|
      element == '0'
    end

    return unless winner == true

    puts announce_winner
    @continue_game = false
  end

  def choice_of_colours
    puts "\nChoice of colours/pegs:\n\n"
    @colours.each do |number|
      print Pegs.map_colours_numbers(number)
    end
  end

  def game_rounds(player_input)
    choice_of_colours
    if defined?(user_create_code)
      user_create_code
    end
    player_input.call until @game_rounds.zero? || @continue_game == false

    return if @continue_game == false && @game_rounds.zero?

    if @game_rounds.zero?
      puts end_of_game
    end
  end

  def shuffle_clues(clues)
    puts "\n\n"
    unless clues.empty?
      puts "Clues:"
    end
    puts clues.shuffle
  end

  def check_correct_clue(player_guess_array, temp_colour_selection)
    clues = []
    player_guess_array.each_index do |p_index|
      temp_colour_selection.each_index do |r_index|
        if player_guess_array[p_index] == temp_colour_selection[r_index] && p_index == r_index
          clues.push(Pegs.correct_clue)
          @correct_clue_pool[p_index] = temp_colour_selection[r_index]
          player_guess_array[p_index] = '0'
          temp_colour_selection[r_index] = '1'
          break
        end
      end
    end
    check_partially_correct_clue(player_guess_array, temp_colour_selection, clues)
  end

  def check_partially_correct_clue(player_guess_array, temp_colour_selection, clues)
    @partially_correct_clue_pool = []

    player_guess_array.each_index do |p_index|
      temp_colour_selection.each_index do |r_index|
        if player_guess_array[p_index] == temp_colour_selection[r_index]
          clues.push(Pegs.partially_correct_clue)
          @partially_correct_clue_pool[p_index] = temp_colour_selection[r_index]
          player_guess_array[p_index] = '2'
          temp_colour_selection[r_index] = '3'
          break
        end
      end
    end

    @game_rounds -= 1
    shuffle_clues(clues)
    declare_winner(player_guess_array)
    return if @continue_game == false

    remaining_rounds
  end

  def remaining_rounds
    puts "\nYou have #{@game_rounds} rounds left\n\n"
  end

  def choose_four_digits(message)
    player_guess_array = []
    loop do
      continue = false
      puts message
      player_guess = gets.chomp.chars
      player_guess.each { |x| player_guess_array.push(x.to_i) }

      player_guess_array.all? do |z|
        if z <= 6 && z >= 1 && player_guess_array.count == 4
          continue = true
        else
          continue = false
        end
      end
      break if continue == true
      player_guess_array = []
    end

    puts "\nSecret code guess:\n\n"
    player_guess_array.each do |number|
      print Pegs.map_colours_numbers(number)
    end

    player_guess_array
  end
end

# The computer guesses the secret code (option 2 of the game)
class ComputerGuessSecretCode < Game
  attr_accessor :temp_colour_selection, :player_guess_array, :player_code, :temp_player_code, :announce_winner, :end_of_game

  def initialize
    super
    @announce_winner = "\nThe computer is the winner!"
    @end_of_game = 'The computer ran out of guesses!'
    game_rounds(method(:intelligent_guess))
  end

  private

  def user_create_code
    puts "\n\nThis is the @random_colour_selection array (this array shouldn't be able to be changed)\n\n"
    @random_colour_selection.each do |number|
      puts Pegs.map_colours_numbers(number)
    end
    message = "\n\nCreate the secret code using 4 coloured pegs (between 1-6):"
    @player_code = choose_four_digits(message)
    computer_guess
  end

  def computer_guess
    @random_colour_selection = []

    4.times do
      @random_colour_selection.push(@colours.sample)
    end

    puts "\n\nThe computer chose:"
    @random_colour_selection.each do |number|
      print "#{Pegs.map_colours_numbers(number)}"
    end

    @temp_colour_selection = @random_colour_selection.clone
    temp_player_code = @player_code.clone
    check_correct_clue(temp_player_code, temp_colour_selection)
  end

  #  Creates the computer's guess with shuffled partially correct clues
  def partially_correct_clue_shuffle
    nil_index = []

    partially_correct_clue_pool.each_index do |index|
      if partially_correct_clue_pool[index].nil?
        nil_index.push(index)
      end
    end

    if !partially_correct_clue_pool.empty? || !partially_correct_clue_pool.all?(nil)
      @partially_correct_clue_pool = @partially_correct_clue_pool.compact.shuffle
    end

    nil_index.each do |element|
      partially_correct_clue_pool[element, 0] = nil
    end
  end

  # Improves the computer's guess by inserting the known correct clues
  def insert_correct_clues
    index = {}

    correct_clue_pool.each_with_index do |element, i|
      unless correct_clue_pool[i].nil?
        index[i] = element
      end
    end

    index.each do |key, value|
      @temp_colour_selection[key] = value
    end
  end

  # Replaces any nil elements in the computers guess with a random peg (colour/number)
  #   and ensures there is a minimum of 4 pegs chosen
  def finalise_computer_guess
    @temp_colour_selection.each_index do |i|
      if @temp_colour_selection[i].nil?
        @temp_colour_selection[i] = @colours.sample
      end
    end

    @temp_colour_selection.push(@colours.sample) until @temp_colour_selection.count == 4
  end

  def intelligent_guess
    sleep 1
    @temp_colour_selection = []
    #puts 'Overall Clue Pools'
    #p "Correct clues: #{correct_clue_pool}"
    #p "Partially correct clues: #{partially_correct_clue_pool}"

    partially_correct_clue_shuffle
    @temp_colour_selection = partially_correct_clue_pool.clone
    insert_correct_clues

    #p "Temp Random Colour Selection: #{@temp_colour_selection}"
    finalise_computer_guess
    #puts "\n\n"
    #puts 'End of intelligent-guess'
    #puts 'Overall Clue Pools'
    #p "Correct clues: #{correct_clue_pool}"
    #p "Partially correct clues: #{partially_correct_clue_pool}"
    #p "Temp Random Colour Selection: #{@temp_colour_selection}"

    puts "\nSecret code guess:\n\n"
    @temp_colour_selection.each do |number|
      print Pegs.map_colours_numbers(number)
    end

    temp_player_code = @player_code.clone
    check_correct_clue(temp_player_code, temp_colour_selection)
  end
end

# User guesses the secret code
class UserGuessSecretCode < Game
  attr_accessor :temp_colour_selection, :player_guess_array, :player_code, :announce_winner, :end_of_game

  def initialize
    super
    @announce_winner = "\nYou are the winner!"
    @end_of_game = 'You ran out of guesses!'
    random_colours
  end

  private

  def user_guess_code
    temp_colour_selection = @random_colour_selection.clone
    message = "\n\nGuess the order and colours of 4 pegs (between 1-6):"
    player_code = choose_four_digits(message)
    check_correct_clue(player_code, temp_colour_selection)
  end

  # Computer creates 4 random colours for the player guessing
  def random_colours
    4.times do
      @random_colour_selection.push(@colours.sample)
    end
    game_rounds(method(:user_guess_code))
  end
end

# User chooses their role (guesser or creator of secret code)
class Role
  include Pegs

  def initialize
    game_instructions
    choose_role
  end

  def game_instructions
    puts "Welcome to Mastermind! \n\nIn this game, you can be either (1) the guesser of the code, or (2) the creator of the secret code.

    Option 1:

    * Choose 4 numbers between 1-6 (no spaces) (e.g. 1234) to guess the computers secret code.
    * Not only do you need to find the correct numbers, but also the correct combination.
    * You will be provided 12 rounds to solve the secret code.

    * There are two different clues that may be provided each round:

    #{Pegs.correct_clue} - This clue indicates one of your four pegs is not only correct, but it's also in the correct position within the secret code.

    #{Pegs.partially_correct_clue} - This clue indicates one of your four pegs is correct, however it's not in the correct position within the secret code.

    Option 2:

    * Create the secret code by choosing 4 coloured pegs (between 1-6).
    * The computer will be provided 12 rounds to guess your secret code.\n\n"

  end

  def choose_role
    select_role = ''
    loop do
      puts 'Press (1) to be the guesser, or (2) to be the creator of the secret code:'
      select_role = gets.chomp
      break if select_role == '1' || select_role == '2'
    end

    case select_role
    when '1'
      UserGuessSecretCode.new
    when '2'
      ComputerGuessSecretCode.new
    end
  end
end

Role.new
