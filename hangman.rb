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
    puts "Secret word: #{@guess_player.word}"
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
    @acceptable_words = word_length_match
    trim_sample
    populate_frequency
    #puts @letter_frequency
    choose_probable_letter
  end
  
  private
  
  def choose_probable_letter
    max_frequency = 0
    max_letter = ""
    @letter_frequency.each do |key, value|
      if value > max_frequency && !@checked_letters.include?(key)
        max_frequency = value 
        max_letter = key
      end
    end
    @checked_letters << max_letter
    puts max_frequency
    puts max_letter
    max_letter 
  end
  
  def populate_frequency
    @letter_frequency = {}
    @dictionary.each do |word|
      word.split("").each do |letter|
        @letter_frequency[letter] ||= 0
        @letter_frequency[letter] += 1
      end
    end
  end
  
  def trim_sample
    found = false
    answer = []
    self.word.length.times do |i|
      if ("a".."z").cover?(self.word[i])
        found = true
        @acceptable_words.each do |word|
          answer << word if self.word[i] == word[i]
        end
      end
    end
    puts answer
    @acceptable_words = answer
  end

  def word_length_match
    @dictionary.select do |word|
      word.length == self.word.length
    end
  end
  
end