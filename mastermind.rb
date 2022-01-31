# frozen_string_literal: true

require 'pry'

# Module for creating pegs with numbers and background colours
module Display
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

# Computer Player
class Computer
  include Display
  def initialize
    @partially_correct_clue = '●'
    @correct_clue = '●'
    @colours = [1, 2, 3, 4, 5, 6]
    @random_colour_selection = []
    @game_rounds = 12
    @continue_game = true
    random_colours
  end

  def random_colours
    4.times do
      @random_colour_selection.push(@colours.sample)
    end
    game_rounds
  end

  def declare_winner(player_guess_array)
    return unless player_guess_array[0] == '0'

    winner = player_guess_array.all? do |element|
      element == '0'
    end

    return unless winner == true

    puts 'Winner!'
    @continue_game = false
  end

  def game_rounds
    puts "Choices of colours/pegs:\n\n"
    @colours.each do |number| 
      puts Display.map_colours_numbers(number)
    end

    guess until @game_rounds.zero? || @continue_game == false
  end

  def guess
    player_guess_array = []
    temp_random_colour_selection = @random_colour_selection.clone
    clues = []
    puts "This is the @random_colour_selection array (this array shouldn't be able to be changed)"
    @random_colour_selection.each do |number|
      puts Display.map_colours_numbers(number)
    end

    loop do
      continue = false
      player_guess_array = []
      puts 'Guess the order and colours of 4 pegs (between 1-6):'
      player_guess = gets.chomp.chars
      player_guess.each { |x| player_guess_array.push(x.to_i) }
      # puts player_guess_array.count

      player_guess_array.any? do |z|
        if z <= 6 && z >= 1 && player_guess_array.count == 4
          continue = true
        end
      end

      break if continue == true
    end

    player_guess_array.each_index do |p_index|
      temp_random_colour_selection.each_index do |r_index|
        # puts "FIRST Iteration:"
        # puts "Player Guess Array:"
        # puts @player_guess_array[p_index]
        # puts "Temp Random Colour Selection:"
        # puts temp_random_colour_selection[r_index]
        if player_guess_array[p_index] == temp_random_colour_selection[r_index] && p_index == r_index
          clues.push(Display.correct_clue)
          player_guess_array[p_index] = '0'
          temp_random_colour_selection[r_index] = '1'
          break
        end
      end
    end

    player_guess_array.each_index do |p_index|
      temp_random_colour_selection.each_index do |r_index|
        if player_guess_array[p_index] == temp_random_colour_selection[r_index]
          clues.push(Display.partially_correct_clue)
          player_guess_array[p_index] = '2'
          temp_random_colour_selection[r_index] = '3'
          break
        end
      end
    end

    # puts "FIRST Iteration:"
    # puts @player_guess_array
    # puts @temp_random_colour_selection
    # puts "Second Iteration:"
    # puts @player_guess_array
    # puts @temp_random_colour_selection

    @game_rounds -= 1
    puts clues
    declare_winner(player_guess_array)
    return if @continue_game == false

    puts "You have #{@game_rounds} rounds left"
  end
end

# User chooses their role (guesser or creator of secret code)
class Role
  def initialize
    choose_role
  end

  def choose_role
    select_role = ''
    loop do
      puts 'Press (1) to be the guesser, or (2) to be the creator of the secret code:'
      select_role = gets.chomp
      break if select_role.include?('1') || select_role.include?('2')
    end

    case select_role
    when '1'
      Computer.new
    when '2'
      puts 'This part of the game has not yet been completed'
    end
  end
end

Role.new
