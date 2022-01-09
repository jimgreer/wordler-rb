# frozen_string_literal: true

require_relative 'wordler'

# Supports playing from the terminal
class Player
  def initialize(length = DEFAULT_WORD_LENGTH, log: false)
    @scorer = Scorer.new(length, log)
    reset
    print_instructions
  end

  def reset
    @wordler = Wordler.new(@scorer)
  end

  def print_instructions
    puts "\nWelcome to Wordler!"
    puts 'I like to play Wordle in hard mode.'
    puts 'I\'ll make guesses, and you tell me the result'
    puts 'You type "g" for green, "y" for yellow, and "." for grey'
  end

  def make_guess
    next_guess_word = @wordler.next_guess

    if next_guess_word.nil?
      lose
      false
    else
      puts
      puts "I guess #{next_guess_word}"
      next_guess_word
    end
  end

  def play
    loop do
      next_guess_word = make_guess
      next unless next_guess_word

      handle_results(next_guess_word)
    end
  end

  def handle_results(next_guess_word)
    puts 'Enter results (for example "ggy...") or "q" to quit'
    print '> '
    results = gets.chomp

    quit if results == 'q'

    if results == 'ggggg' || results.empty?
      win
    else
      @wordler.enter_guess(Guess.new(next_guess_word, results))
    end
  end

  def lose
    puts "\nI lose. Let\'s play again!"
    puts '------'
    reset
  end

  def win
    puts "\nI win. Let\'s play again!"
    puts '------'
    reset
  end

  def quit
    puts 'Thanks for playing!'
    exit
  end
end

Player.new.play
