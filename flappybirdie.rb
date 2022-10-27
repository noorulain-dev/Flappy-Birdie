# Encoding: UTF-8
require 'rubygems'
require 'gosu'



#setting the constant variable value in pixels per second squared
ANIMATION = 500
BOUNCE = 275



# The following determines which layers things are placed on on the screen
# background is the lowest layer (drawn over by other layers), user interface objects are highest.
module ZOrder

  BACKGROUND, MIDDLE, TOP = *0..2
  
end



# setting constants for the window width and window height respectively 
# the size of the window is set according to the size of the background image to fit the window 
WIN_WIDTH = 360
WIN_HEIGHT = 640


class GameWindow < Gosu::Window



# initializing the function variables to be used later
   def initialize

#initializing the height and width of the screen 
       super(WIN_WIDTH, WIN_HEIGHT, false)

# setting the caption which appears on the top bar of the window
	   self.caption="Flappy Birdie by Noor Ul Ain"

#setting the mode at which the game begins
       @player_mode = :startmode


       @header_style = Gosu::Font.new(self, Gosu::default_font_name, 50)
	
	   @points_style = Gosu::Font.new(self, Gosu::default_font_name, 20)

#routing images and specifying their paths and assigning them to a variable
	   @background= Gosu::Image.new("images/skyy.png")

       @foreground= Gosu::Image.new("images/grnd.jpg")

	   @swipe_x= 0

#introducing a new class pipe

	   @pipe = Pipe.new(self)
	
	   @current_points = 0

	   @max_points = 0
	 
	   @birdie_y_speed = 0
		
# setting the value of variable bird y to specify the y coordinate of the bird image
    
	   @birdie_y = 300
	
       @intro= Gosu::Image.new("images/intro.png")
	
	   @points_style= Gosu::Font.new(self, Gosu::default_font_name, 24)

#new class birdie
	   @birdie = Birdie.new(self)

#routing the sound effects to be played during the game

	   @sound_effects=Gosu::Sample.new("sound/tune.ogg")
	
	   @sound_effects.play
	   
	   @game_over= Gosu::Image.new(self,"images/gameover.png",true)
	
	
   end

# the play mode specifies the state of the game player i.e if it is playing or if the game is over
   def play_mode(mode)
      
	  @player_mode = mode
	  
   end
	
#hit obstacle function calls the pipe class and sends the value of birdie_y variable 
   def hit_obstacle(birdie_y)
   
      @pipe.hit_obstacle(@birdie_y)
	  
   end


   def draw

     @background.draw(0, 0, ZOrder::BACKGROUND)

     @foreground.draw(-@swipe_x, 500, ZOrder::TOP)

	 @foreground.draw(-@swipe_x+@foreground.width, 500, ZOrder::TOP)
	
     @pipe.draw
	 
# if the game is starting i.e if it is back to it's original screen then the intro variable will be drawn on the screen 
     if @player_mode == :startmode
	
     @intro.draw(75, 150, ZOrder::TOP)
	
	 end

	 @birdie.draw(@birdie_y)
	 
# if the player mode of the game is off i.e the game is over then the reset function will be called  
	reset if @player_mode == :off
	
# if the player mode is on then the following will display in the corner of the screen which will show the c=user the current points scored 
	 if @player_mode== :on
	

	 @points_style.draw("Score: #{@current_points}", 10,10,10,1,1 ,Gosu::Color::BLACK)
     
	 end

end 

#the points will zeroize i.e become zero once the game is restarted
	
   def points_zeroize
   
      @current_points = 0
	  
   end
	


   def update

      if @player_mode == :on 
# if the player mode is on then the swipe x variable will update by decreasing with a value of 5
# this will make the bottom part of the screen slide of the left   
          @swipe_x += 5
	   
          @pipe.update
	   
# update_interval is a method which returns the milliseconds that are overlapsed in a frame between each call of the function
# dividing the update interval by 1000.0 to convert milliseconds into seconds

	     @birdie_y_speed += ANIMATION * (update_interval/1000.0)
	  
# updating the value of position of the bird_y variable according to the value of speed of bird_y_speed
# update_interval is cited from https://www.rubydoc.info/github/gosu/gosu/master/Gosu%2FWindow:update_interval

	     @birdie_y += @birdie_y_speed * (update_interval/1000.0)
	  
	        if @swipe_x > @foreground.width
 #once the value of swipe x becomes greater than the value of foreground then it's value will reset and this way a loop will be created 		 
               @swipe_x=0
			
            end
		 
	    	@pipe.hit_obstacle(@birdie_y)
		
		   @birdie.update
		
      end 

   end

	
   def plus_points
#this function willupdate current points of the game by 1
      @current_points += 1
   
   end


   def button_down(button)


      if @player_mode == :startmode
# if the user is on the titlescreen and the user presses space then the game will begin    
	     if button == Gosu::KbSpace
	       
 		   @player_mode = :on
	    
		 end
	 
      end

        if @player_mode == :on
# if the user is playing the game and presses the escape key then the game will end          
  		   @player_mode = :off if button == Gosu::KbEscape
              
			  if button == Gosu::KbSpace		
# whenever the user presses a spacebar, the bird will bounce with a negative y value		 
		         @birdie_y_speed = -BOUNCE
	 
	          end
        end

      if @player_mode == :off
# if the game is off and the user presses space bar then the user will be taken to the startmode	  
         @player_mode = :startmode if button==Gosu::KbSpace
		 
      end
      close if button==Gosu::KbEscape
   end


# once the game is over and everything resets then the following texts will display on the screen
   def reset

      @game_over.draw(50, 270, ZOrder::TOP)

      if @current_points > @max_points
		
         @max_points = @current_points
			
         remarks = "CONGRATULATIONS! New Top Achievement! #{@max_points}"
     else
		
         remarks = "You gained #{@current_points} points\n Highest achievement: #{@max_points}"
     end
	
	
         @header_style.draw(remarks, 100, 320 , ZOrder::TOP, 0.4, 0.4, Gosu::Color::BLACK)
	
     end

   end


#new class pipe
class Pipe


   def initialize(screen, x_offset=0)

      @screen = screen
	  
      @x_offset = x_offset
	  
      @pipe= Gosu::Image.new(screen, "images/pipe.png")
	  
      @x=360
	  
      @y=rand(-250..0)
	  
      @fall_sound_effect=Gosu::Sample.new(screen, 
      "sound/hit.ogg")
	  
      @score_sound_effect=Gosu::Sample.new(screen, "sound/point.ogg")
	  
end

	
   def zeroize
# a random number is generated for the y variable between -250 and 0   
      @y = rand(-250..0)
	  
      @x = 360 + @x_offset
	  
      @screen.plus_points
	  
      @score_sound_effect.play
	  
   end
	
	
   def update
   
      @x -= 5
# updating the value of x coordinate of game by negative 5 and oncei= the value becomes less than -190, then the zeroize function will be called	  
      zeroize if @x < -190

   end

	
   def draw  
		
      @pipe.draw(@x, @y+420, ZOrder::MIDDLE)
	  
# the pipe is drawn rotated at an angle of 180 degrees
#the pipe is drawn in the middle so the foreground appears on top of it and gives the illusion that the pipe is starting from above the foreground

      @pipe.draw_rot(@x+175, @y, ZOrder::MIDDLE, 180)

   end

# if the bird hits any obstacles then the play mode of the game willbe off and the value willbe sent to the play_mode function in the main class
	
	def hit_obstacle(birdie_y)
# the initial value of the x and y collide are false and for those values to be true, a few conditions must be fulfilled	
      y_collide = x_collide = false
	  
      x_collide = true if @x<-100
	  
      y_collide=true if birdie_y<0
	  
      y_collide= true if birdie_y>480
	  
      y_collide=true if birdie_y>@y+410 || birdie_y<@y+310
	  
         if y_collide== true && x_collide==true
	  
         then @screen.play_mode(:off)
	  
      @fall_sound_effect.play
	  
         end
		 
    end
	
end


#new class birdie 
class Birdie

   def initialize (screen)

#introducing 2 birds and their images in an array to animate the object 
#array of the red birdie images 
      @birdie_red= [Gosu::Image.new(screen, "images/red3.png"),Gosu::Image.new(screen, "images/red2.png"),Gosu::Image.new(screen, "images/red1.png"),Gosu::Image.new(screen, "images/red3.png")]

#array of the yellow birdie images
      @birdie_yellow= [Gosu::Image.new(screen, "images/yellow3.png"),Gosu::Image.new(screen,"images/yellow2.png"),Gosu::Image.new(screen,"images/yellow1.png"),Gosu::Image.new(screen, "images/yellow3.png")]
	    
      @a=360
	
      @b=0

   end


 
   def zeroize 

      @a=360
      @b+=1
   end

#the color of the bird changes alternately between each points
   def draw(birdie_y)

      i = Gosu::milliseconds / 75 % @birdie_yellow.size
      j = Gosu::milliseconds / 75 % @birdie_red.size	
	
         if @b%2==0
# if the value of b is divisible by 2 then the yellow bird will be displayed		 
            @birdie_yellow[i].draw(50, birdie_y, ZOrder::TOP)
		
         else 
# else the red bird will be displayed		 
	        @birdie_red[j].draw(50, birdie_y, ZOrder::TOP)
         
		 end

   end


   def update

          @a -= 5
	
          zeroize if @a<0

   end


end





window = GameWindow.new
window.show

