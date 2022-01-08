require_relative 'wordler'

class Player
  def initialize(length = DEFAULT_WORD_LENGTH, log: false)
    @scorer = Scorer.new(length, log:)
    reset
  end

  def reset
    @wordler = Wordler.new(@scorer)
  end

  def make_guess
    next_guess_word = @wordler.next_guess

    if next_guess_word.nil?
      lose
      false
    else
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
    puts 'Enter results'
    results = gets.chomp
    if results == 'ggggg' || results.empty?
      win
    else
      @wordler.enter_guess(Guess.new(next_guess_word, results))
    end
  end

  def lose
    puts 'I lose. Let\'s play again!'
    puts '------'
    reset
  end

  def win
    puts 'I win. Let\'s play again!'
    puts '------'
    reset
  end
end

Player.new(log: true).play
