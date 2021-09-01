require 'ruby2d'
x='blue'

set background: 'white' #background color
REC_WIDTH=(Window.width/100*20)+(Window.width/100*70) # width of the rectangular board
DISTANCE_CIRCLES=70 # distance between the circles(design)

class Game
  attr_reader :turn
  def initialize
    @finished = false
    $full_column = [false,false,false,false,false,false,false] # array to check with column of the board is full
    $board_array=[] # array to check where the pieces are inserted in which columns
    $board_array_fill = [] # array to hold the color of the pieces,1 for yellow,2 for red used to find out the winner
    @player_num=1
    @turn = 0
    @player_turn = Text.new("Player #{(@turn%2)+1}'s Turn",style:'italic', color:'red') # display the player's turn
    for a in 0..6
      $board_array.push([]) #make this a 2d array
      $board_array_fill.push([]) # make this a 2d array
      for b in 0..6
        $board_array[a].push(false) # boolean 2d array
        $board_array_fill[a].push(false) # boolean 2d array
      end
    end
  end

  def draw
    rec=Rectangle.new(x: 50, y: 50, width: REC_WIDTH, height: 400,
      color: 'blue') # draw blue board
    rec.opacity=0.8 # opacity of the board
    circle_x=105
    for a in 0..6
      circle_y=100
      for b in 0..6
        circ = Circle.new(x: circle_x, y: circle_y, radius: 24, sectors: 30, color: 'white',)  # draw empty circles (circles with no pieces inside)
        if $board_array[a][b]
          if $board_array_fill[a][b]==false # check if this is false before inserting a number
            $board_array_fill[a][b]=(@turn%2)+1 # insert a number into this array depending on color piece
          end
          if $board_array_fill[a][b]%2==0 # draw a circle where the color depends on which player has to move
            piece_color ='red' # draw red circle
          else
            piece_color ='yellow' # draw yellow circle
          end
          circ = Circle.new(x: circle_x, y: circle_y, radius: 24, sectors: 30, color: piece_color) # draw yellow or red circle
          #print a," ",b," "
        end
        circle_y+=50
      end
      circle_x+=70
    end
  end

  def column_full?(x)
    $board_array[x].all?{|y| y==true} # check if column of the board is full
  end

  def turn_remove
    @player_turn.remove
  end

  def coordinates_mouse(x,y)
    $board_array_fill.each do |x|
      print x,"\n"
    end
    #print $board_array
    coord_x=70*7
    for a in 6.downto(0)
      s=Square.new(x:coord_x,y:0,color:'white',size:60) # check coordinates of the mouse  if it touches an empty circle on the board
      s.opacity=0
      coord_x-=DISTANCE_CIRCLES
      if s.contains?(x,y)
        for b in 6.downto(0)
          if column_full?(a)==false
            if $board_array[a][b]==false # fill in array that a piece occupies this cell
              @player_turn.remove
              new_turn = 1+@turn

              @player_turn=Text.new("Player #{(new_turn%2)+1}'s Turn",style:'italic', color:'red')
              @turn+=1
              $board_array[a][b]=true
              break
            end
          end
        end
      end
    end
  end
  def game_over_text # display end game report
    if check_board && !check_winner
      Text.new("The result is a draw! Press 'R' to restart",x:Window.width/100*30,y:0,color:'red') # display a draw
    else Text.new("Player #{((@turn+1)%2)+1} wins! Press 'R' to restart",x:Window.width/100*30,y:0,color:'red')
    end
  end

  def finished? # check if the game ended
    @finished
  end
  def game_finish # boolean value to end the game
    @finished=true
  end

  def check_board # check if each column of the board is full, if so, end the game
    $board_array.each do |x|
      return false if !(x.all?{|y| y==true})
    end
    game_finish
    true
  end

  def check_winner # check the winner of the game depending on the number of consecutive color pieces
    #red =2, yellow=1
    for a in 0..6 #vertical column winner
      v_red=0
      v_yellow=0
      for b in 0..6
        if $board_array_fill[a][b]==2 # check if this array has a red piece
          v_red+=1 # increase red consecutive counter
          v_yellow=0  # set yellow consecutive counter to 0
          # print v_red," "
        elsif $board_array_fill[a][b]==1 # check if this array has a yellow piece
          v_yellow+=1 # increase yellow consecutive counter
          v_red=0 # set red consecutive counter to 0
        end
        if v_red==4||v_yellow==4 # number of consecutive pieces is equal to 4
          @finished=true # we  end the game here
        end
      end
    end
    for a in 0..$board_array_fill.size-1 # check down-right or up-left winner
      for b in 0..$board_array_fill.size-1
        col = b
        x=0
        y=0
        for row in a.downto(0)
          if $board_array_fill[row][col]==2
            y+=1
            x=0
          elsif $board_array_fill[row][col]==1
            x+=1
            y=0
          end
          if x==4
            game_finish
          elsif y==4
            game_finish
          end
          if col>=$board_array_fill.size
            break
          end

          col+=1
        end
      end
    end
    for a in 0..$board_array_fill.size-1 # check down-left or up-right winner
      for b in 0..$board_array_fill.size-1
        col = b
        x=0
        y=0
        for row in a..$board_array_fill.size-1
          if $board_array_fill[row][col]==2
            y+=1
            x=0
          elsif $board_array_fill[row][col]==1
            x+=1
            y=0
          end
          if x==4
            game_finish
          elsif y==4
            game_finish
          end
          if col>=$board_array_fill.size
            break
          end

          col+=1
        end
      end
    end


    for a in 0..$board_array_fill.size-1 # check horizontal winner
      x=0
      y=0
      for b in 0..$board_array_fill.size-1
        if $board_array_fill[b][a]==2
          x+=1
          y=0
        elsif $board_array_fill[b][a]==1
          y+=1
          x=0
        end
        if x==4 || y==4
          @finished=true
        end
      end
    end
    false # false if no winner was found
  end
end


game = Game.new


update do
  game.draw
  game.check_winner
  game.check_board
  if game.finished?
    game.turn_remove
    game.game_over_text
  end
end

on :key_down do |event|
  if game.finished? && event.key=='r'
    clear
    game=Game.new # create a new game
  end
end


on :mouse_down do |event|
  unless game.finished?
    game.coordinates_mouse(event.x,event.y) # record mouse coordinates
  end
end

show
