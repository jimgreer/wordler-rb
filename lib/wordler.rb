require 'set'
require 'debug'
require_relative 'scorer'
require_relative 'util'

class Guess
  GREEN = 'g'.freeze
  YELLOW = 'y'.freeze
  GREY = '.'.freeze

  def initialize(word, results)
    @word = word.upcase
    @results = results
  end

  attr_reader :word, :results
end

# Board state is a five element array of sets.
# Each set contains the possible letters for that slot.

# As guesses are made, the board state is updated to include only letters that remain valid.
# The dictionary is then filtered to only include words that remain possible
class Wordler
  attr_reader :dictionary, :scorer

  def initialize(scorer)
    @board = Array.new(DEFAULT_WORD_LENGTH) { Set.new(('A'..'Z').to_a) }
    @excluded_letters = Set.new
    @included_letters = Set.new
    @dictionary = load_words(DEFAULT_WORD_LENGTH)
    @scorer = scorer
    @hard_mode = true
    @first_guess = true
  end

  def enter_guess(guess)
    guess.word.chars.each_with_index do |letter, slot|
      handle_result(guess.results[slot], letter, slot)
    end

    update_dictionary
  end

  def handle_result(result, letter, slot)
    case result
    when Guess::GREEN
      @board[slot] = Set.new([letter])
      @included_letters << letter
    when Guess::YELLOW
      @board[slot].delete(letter)
      @included_letters << letter
    when Guess::GREY
      @excluded_letters.add(letter) unless @included_letters.include?(letter)
    end
  end

  def includes_excluded_letters?(word)
    @excluded_letters.each do |letter|
      return true if word.include?(letter)
    end
    false
  end

  def includes_all_included_letters?(word)
    @included_letters.each do |letter|
      return false unless word.include?(letter)
    end
    true
  end

  def word_matches_board?(word)
    word.chars.each_with_index do |letter, i|
      return false unless @board[i].include?(letter)
    end
    true
  end

  def word_valid?(word)
    return false if includes_excluded_letters?(word)
    return false unless includes_all_included_letters?(word)
    return false unless word_matches_board?(word)

    true
  end

  def update_dictionary
    @dictionary.select! { |word| word_valid?(word) }
  end

  def next_guess
    return nil if @dictionary.empty?

    guess = @scorer.make_guess(dictionary: @dictionary, first_guess: @first_guess)
    @first_guess = false
    guess
  end
end
