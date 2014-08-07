class Hangman
  def initialize
    @guessed_letters = []
  end
  
  def update_guessed_letter(letter)
    @guessed_letters << letter
  end
  
  def already_guessed?(letter)
    @guessed_letters.include?(letter)
  end
end

class Game
  attr_accessor :guess_player, :check_player
  
  def initialize(guessing_player = HumanPlayer, check_player = ComputerPlayer)
    @guess_player = guessing_player.new
    @check_player = check_player.new
    @hangman = Hangman.new
  end
  
  def play
    @check_player.word = @check_player.get_word
    @guess_player.word = "_" * @check_player.word.length
    @guess_counter = @check_player.word.length
    until solved? || @guess_counter == 0
      display_hint
      guess_letter = @guess_player.guess_letter
      break if guess_letter == "quit"
      correct = @check_player.evaluate_guess(guess_letter, @guess_player)
      update_guess_counter(guess_letter) unless correct
      @hangman.update_guessed_letter(guess_letter)
    end
    puts "The word was: #{@check_player.word}"
    puts solved? ? "You win!" : "You lose!"
  end
  
  private
  
  def update_guess_counter(letter)
    @guess_counter -= 1 unless @hangman.already_guessed?(letter)
  end
    
  def display_hint
    puts "You have #{@guess_counter} guesses remaining."
    puts "Secret word:    #{@guess_player.word}"
    puts "Letter Indices: #{(0...@guess_player.word.length).to_a.join("")}"
  end

  def solved?
    @guess_player.word == @check_player.word
  end
end

class Player
  attr_accessor :word
  
  def initialize
    @word = ""
  end
  
  def update_word(index, letter)
    self.word[index] = letter
  end
  
  def valid_guess?(letter)
    ("a".."z").cover?(letter)
  end
end

  
class HumanPlayer < Player
  def initialize
  end

  def evaluate_guess(letter, guess_player)
    puts "In which position(s) does your word have '#{letter}'?"
    positions = gets.chomp.split.map(&:to_i)
    positions.each do |index|
      guess_player.update_word(index, letter)
      self.update_word(index, letter)
    end
    
    !positions.empty?
  end
  
  def get_word
    word_length = 0
    until (1..50).cover?(word_length)
      print "Please enter word length >"
      word_length = gets.chomp.to_i
    end
    
    "-" * word_length
  end
  
  def guess_letter
    while true
      print "Guess a letter > "
      user_guess = gets.chomp.downcase
      return "quit" if user_guess == "quit"
      return user_guess if valid_guess?(user_guess)
    end
  end
end

class ComputerPlayer < Player
  def initialize(file = "dictionary.txt")
    @dictionary = File.read(file).split
    @checked_letters = []
  end
  
  def evaluate_guess(letter, guess_player)
    correct = false
    guess_player.word.length.times do |i|
      if self.word[i] == letter
        guess_player.word[i] = letter
        correct = true
      end
    end
    
    correct
  end
  
  def get_word
    @dictionary.sample
  end
  
  def guess_letter
    possible_words = match_words_by_index(match_words_by_length)
    letter_frequency = letter_frequency(possible_words)
    choose_probable_letter(letter_frequency)
  end
  
  private
  
  def match_words_by_length
    @dictionary.select do |word|
      word.length == self.word.length
    end
  end
  
  def match_words_by_index(possible_words)
    user_word = map_letter_index(self.word)
    possible_words.select do |word|
      test_word = map_letter_index(word)
      match_word_index?(user_word, test_word)
    end
  end
  
  def match_word_index?(original_word_index, test_word_index)
    original_word_index.each do |letter, index|
      return false unless test_word_index[letter] == index
    end
    true
  end
  
  def choose_probable_letter(frequency)
    max_letter = ""
    max_frequency = 0
    
    frequency.each do |letter, frequency|
      if frequency > max_frequency && !@checked_letters.include?(letter)
        max_letter = letter
        max_frequency = frequency
      end
    end
    
    @checked_letters << max_letter
    max_letter 
  end
  
  def letter_frequency(possible_words)
    frequency = {}
    
    possible_words.each do |word|
      word.split("").each do |letter|
        frequency[letter] ||= 0
        frequency[letter] += 1
      end
    end
    
    frequency
  end
  
  def map_letter_index(str)
    letter_index = {}
    
    str.split("").each_with_index do |letter, index|
      if letter =~ /[a-z]/
        letter_index[letter] = index
      end
    end
    
    letter_index
  end
  
end