class Hangman
  def self.generate_word(file = "dictionary.txt")
    File.read(file).split.sample
  end
end

class Game
  def initialize(guessing_player = HumanPlayer, checking_player = ComputerPlayer)
    @guess_player = guessing_player.new
    @check_player = checking_player.new
  end
  
  def play
    player_guesses if @check_player.class == ComputerPlayer
    
    puts "Game over!"
  end
  
  def player_guesses
    @word = Hangman.generate_word
    @correct_guess = Array.new(@word.length) {"_"}
    @guess_counter = @word.length
    @all_player_guesses = []
    until solved? || @guess_counter == 0
      display_hint
      user_guess = @guess_player.guess_prompt
      return "Exiting..." unless user_guess
      update_word(user_guess)
    end
    puts "The word is: #{@word}."
    puts @guess_counter > 0 ? "You win!" : "You lose!"
  end
  
  def update_word(user_guess)
    correct = false
    @word.length.times do |i|
      if same_letter?(i, user_guess)
        @correct_guess[i] = user_guess
        correct = true
      end
    end
    update_guess_counter(correct, user_guess)
    @all_player_guesses << user_guess
  end
  
  private
  
  def update_guess_counter(correct_guess, user_guess)
    unless correct_guess || @all_player_guesses.include?(user_guess)
      @guess_counter -= 1
    end
  end
    
  def display_hint
    puts "You have #{@guess_counter} guesses remaining."
    puts "Secret word: #{@correct_guess.join}"
  end
  
  def same_letter?(index, letter)
    @word[index] == letter
  end
  
  def solved?
    @word == @correct_guess.join
  end
  
end

class Player
  def guess_prompt
  end
  
end
  
class HumanPlayer < Player
  def initialize
  end
  
  def turn(game_role)
    if game_role == "guesser"
      guess_prompt 
    else
      display_result
    end
  end
  
  def guess_prompt
    while true
      print "Guess a letter > "
      user_guess = gets.chomp.downcase
      return false if user_guess == "quit"
      return user_guess if valid_guess?(user_guess)
    end
  end
  
  def valid_guess?(letter)
    ("a".."z").cover?(letter)
  end
  
end

class ComputerPlayer < Player
  def initialize
  end
  
  def turn(game_role)
    if game_role == "guesser"
      guess_prompt 
    else
      display_result
    end
  end
  
  def guess_prompt
    ("a".."z").to_a.sample
  end
end