class Game
  
  def self.colors
    %w(red green blue yellow orange purple)
  end
  
  def initialize(colors = self.class.colors, num = 4)
    @colors = colors
    @computer_colors = colors.sample(num)
    @num = num
  end
  
  def play
    count = 0
    while count <= 10
      puts "You have #{10 - count} tries left"
      user_prompt
      return "You quitter... :|" unless @user_colors
      if won?
        return "You won!"
      else
        display_hints
      end
            
      count += 1
    end
    return "You lost!"
  end  

  private
  
  def display_hints
    colors_in_position = Array.new(@num)
    colors_in_array = []
    
    @num.times do |i|
      colors_in_position[i] = @user_colors[i] if same_color?(i)
      if @computer_colors.include?(@user_colors[i])
        colors_in_array << @user_colors[i]
      end
    end
    
    puts "Here are the exact matches"
    p colors_in_position
    puts "Here are the correct colors, out of place"
    p colors_in_array
  end
  
   
   
  def same_color?(index)
    @user_colors[index] == @computer_colors[index]
  end
  
  def won?
    @user_colors == @computer_colors
  end
  
  def user_prompt
    @user_colors = []
    while @user_colors.length < @num
      puts "Pick a color from #{@colors}: "
      color = gets.chomp.downcase
      @user_colors << color if valid_color?(color)
      
      if color == "quit"
        @user_colors = false
        break
      end
    end
  end
  
  def valid_color?(color)
    @colors.include?(color) && !@user_colors.include?(color)
  end
end