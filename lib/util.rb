# frozen_string_literal: true

DEFAULT_WORD_LENGTH = 5
def load_words(length = DEFAULT_WORD_LENGTH)
  words = []

  File.open('dict/wikipedia-top.txt', 'r').each_line do |line|
    word, = line.chomp.split
    word.upcase!

    next unless word.length == length
    next unless word =~ /^[A-Z]+$/

    words << word
  end

  # remove proper names by intersecting with scrabble dictionary
  words &= load_raw_words('dict/scrabble.txt', length)
end

def load_raw_words(filename, length)
  words = []
  File.open(filename, 'r').each_line do |line|
    words << line.chomp.upcase if line.chomp.length == length
  end
  words
end
