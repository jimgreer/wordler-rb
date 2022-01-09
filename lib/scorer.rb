# frozen_string_literal: true

require_relative 'util'

# Guesses the next word
class Scorer
  DEFAULT_DUPE_PENALTY = 0.25
  FIRST_GUESS = 'AROSE'

  def initialize
    @word_length = DEFAULT_WORD_LENGTH
    @dupe_penalty = DEFAULT_DUPE_PENALTY
    @log = false
  end

  def make_guess(dictionary:, first_guess: false)
    return FIRST_GUESS if first_guess

    # letter frequency per slot of remaining words in dictionary
    @dictionary = dictionary
    @score_log = {}

    calculate_letter_frequencies
    calculate_word_frequencies
    # sort dictionary by score
    @dictionary = sort_dictionary
    @dictionary.take(10).each { |word| puts("#{word}: #{@score_log[word]}") } if @log
    @dictionary.first
  end

  def calculate_letter_frequencies
    @letter_frequencies = Array.new(@word_length) { Hash.new(0) }
    @dictionary.each do |word|
      word.chars.each_with_index do |letter, slot|
        @letter_frequencies[slot][letter] += 1
      end
    end
  end

  def calculate_word_frequency(word)
    word.chars.each_with_index do |letter, slot|
      @word_frequencies[word] += @letter_frequencies[slot][letter]
    end

    @word_frequencies[word] += @word_length
  end

  def calculate_word_frequencies
    @word_frequencies = Hash.new(0)
    max_word_frequency = 0

    @dictionary.each do |word|
      word_frequency = calculate_word_frequency(word)
      @word_frequencies[word] = word_frequency
      max_word_frequency = word_frequency if word_frequency > max_word_frequency
    end

    normalize_word_frequencies(max_word_frequency)
  end

  def normalize_word_frequencies(max_word_frequency)
    @word_frequencies.each do |word, frequency|
      @word_frequencies[word] = Float(frequency) / max_word_frequency
    end
  end

  def score_word(word)
    frequency_score = @word_frequencies[word]

    dupes = count_duplicates(word)
    penalty = dupes * @dupe_penalty
    overall_score = frequency_score - penalty
    penalty_log = penalty.positive? ? " - #{penalty}" : ''

    @score_log[word] = "#{frequency_score.round(2)}#{penalty_log} = #{overall_score.round(2)}"
    overall_score
  end

  def count_duplicates(word)
    word.chars.each_with_object(Hash.new(0)) { |letter, counts| counts[letter] += 1 }
        .values.count { |v| v > 1 }
  end

  def sort_dictionary
    @score_log.clear
    @dictionary.sort_by { |word| score_word(word) }
               .reverse
  end
end
