# frozen_string_literal: true

require 'pry'

# Colours of Pegs
class String
  def bg_red
    "\e[41m  #{self}  \e[0m"
  end

  def bg_blue
    "\e[44m  #{self}  \e[0m"
  end

  def bg_green
    "\e[42m  #{self}  \e[0m"
  end

  def bg_magenta
    "\e[45m  #{self}  \e[0m"
  end

  def bg_yellow
    "\e[43m  #{self}  \e[0m"
  end

  def bg_cyan
    "\e[46m  #{self}  \e[0m"
  end

  def font_black
    "\e[30m#{self}\e[0m"
  end

  def font_red
    "\e[31m#{self}\e[0m"
  end

  def font_grey
    "\e[37m#{self}\e[0m"
  end

  def one_red
    one_red = '1'
    one_red.bg_red.font_black
  end

  def two_blue
    two_blue = '2'
    two_blue.bg_blue.font_black
  end

  def three_green
    three_green = '3'
    three_green.bg_green.font_black
  end

  def four_magenta
    four_magenta = '4'
    four_magenta.bg_magenta.font_black
  end

  def five_yellow
    five_yellow = '5'
    five_yellow.bg_yellow.font_black
  end

  def six_cyan
    six_cyan = '6'
    six_cyan.bg_cyan.font_black
  end

  def correct_clue
    correct_clue = '●'
    correct_clue.font_red
  end

  def partially_correct_clue
    partially_correct_clue = '●'
    partially_correct_clue.font_grey
  end
end

# Computer Player
class Computer < String
  def initialize
    @colours = [one_red, two_blue, three_green, four_magenta, five_yellow, six_cyan]
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
    return unless player_guess_array[0].zero?

    winner = player_guess_array.all? do |element|
      element == 0
    end

    return unless winner == true

    puts 'Winner!'
    @continue_game = false
  end

  def game_rounds
    puts "Choices of colours/pegs:\n\n"
    puts @colours
    guess until @game_rounds.zero? || @continue_game == false
  end

  def guess
    player_guess_array = []
    temp_random_colour_selection = @random_colour_selection.clone
    clues = []
    puts "This is the @random_colour_selection array (this array shouldn't be able to be changed)"
    puts @random_colour_selection

    loop do
      continue = false
      player_guess_array = []
      puts 'Guess the order and colours of 4 pegs (between 1-6):'
      player_guess = gets.chomp.chars
      player_guess.each { |x| player_guess_array.push(x.to_i) }
      puts player_guess_array.count

      if player_guess_array.any? { |z| z <= 6 && z >= 1 && player_guess_array.count == 4}
        continue = true
      end

      break if continue == true
    end

    player_guess_array.each_index do |i|

      case player_guess_array[i]

      when 1
        player_guess_array[i] = one_red

      when 2
        player_guess_array[i] = two_blue

      when 3
        player_guess_array[i] = three_green

      when 4
        player_guess_array[i] = four_magenta

      when 5
        player_guess_array[i] = five_yellow

      when 6
        player_guess_array[i] = six_cyan
      end
    end

    player_guess_array.each_index do |p_index|
      temp_random_colour_selection.each_index do |r_index|
        # puts "FIRST Iteration:"
        # puts "Player Guess Array:"
        # puts @player_guess_array[p_index]
        # puts "Temp Random Colour Selection:"
        # puts temp_random_colour_selection[r_index]
        if player_guess_array[p_index] == temp_random_colour_selection[r_index] && p_index == r_index
          clues.push(correct_clue)
          player_guess_array[p_index] = 0
          temp_random_colour_selection[r_index] = 1
          break
        end
      end
    end

   # puts "FIRST Iteration:"
   # puts @player_guess_array
   # puts @temp_random_colour_selection

    player_guess_array.each_index do |p_index|
      temp_random_colour_selection.each_index do |r_index|
         # puts "Second Iteration:"
         # puts "Player Guess Array:"
         # puts player_guess_array[p_index]
         # puts "Temp Random Colour Selection:"
         # puts temp_random_colour_selection[r_index]
        if player_guess_array[p_index] == temp_random_colour_selection[r_index]
          clues.push(partially_correct_clue)
          # puts clues
          player_guess_array[p_index] = 2
          temp_random_colour_selection[r_index] = 3
          break
        end
      end
    end

    # puts "Second Iteration:"
    # puts @player_guess_array
    # puts @temp_random_colour_selection

    @game_rounds -= 1
    puts clues.shuffle
    declare_winner(player_guess_array)
    return if @continue_game == false

    puts "You have #{@game_rounds} rounds left"
  end
end

game = Computer.new
