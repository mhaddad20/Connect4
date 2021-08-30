require 'ruby2d'
x='blue'

set background: 'white'
REC_WIDTH=(Window.width/100*20)+(Window.width/100*70)
DISTANCE_CIRCLES=70

class Game
  attr_reader :turn
  def initialize
    @finished = false
    $full_column = [false,false,false,false,false,false,false]
    $board_array=[]
    $board_array_fill = []
    @player_num=1
    @turn = 0
    @player_turn = Text.new("Player #{(@turn%2)+1}'s Turn",style:'italic', color:'red')
    for a in 0..6
      $board_array.push([])
      $board_array_fill.push([])
      for b in 0..6
        $board_array[a].push(false)
        $board_array_fill[a].push(false)
      end
    end
  end

  def draw
    rec=Rectangle.new(x: 50, y: 50, width: REC_WIDTH, height: 400,
      color: 'blue')
    rec.opacity=0.8
    circle_x=105
    for a in 0..6
      circle_y=100
      for b in 0..6
        circ = Circle.new(x: circle_x, y: circle_y, radius: 24, sectors: 30, color: 'white',)
        if $board_array[a][b]
          if $board_array_fill[a][b]==false
            $board_array_fill[a][b]=(@turn%2)+1
          end
          if $board_array_fill[a][b]%2==0
            piece_color ='red'
          else
            piece_color ='yellow'
          end
          circ = Circle.new(x: circle_x, y: circle_y, radius: 24, sectors: 30, color: piece_color)
          #print a," ",b," "
        end
        circle_y+=50
      end
      circle_x+=70
    end
  end

  def column_full?(x)
    $board_array[x].all?{|y| y==true}
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
      s=Square.new(x:coord_x,y:0,color:'white',size:60)
      s.opacity=0
      coord_x-=DISTANCE_CIRCLES
      if s.contains?(x,y)
        for b in 6.downto(0)
          if column_full?(a)==false
            if $board_array[a][b]==false
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
  def game_over_text
    if check_board && !check_winner
      Text.new("The result is a draw! Press 'R' to restart",x:Window.width/100*30,y:0,color:'red')
    else Text.new("Player #{((@turn+1)%2)+1} wins! Press 'R' to restart",x:Window.width/100*30,y:0,color:'red')
    end
  end

  def finished?
    @finished
  end
  def game_finish
    @finished=true
  end

  def check_board
    $board_array.each do |x|
      return false if !(x.all?{|y| y==true})
    end
    game_finish
    true
  end

  def check_winner
    #red =2, yellow=1
    for a in 0..6 #vertical column winner
      v_red=0
      v_yellow=0
      for b in 0..6
        if $board_array_fill[a][b]==2
          v_red+=1
          v_yellow=0
          # print v_red," "
        elsif $board_array_fill[a][b]==1
          v_yellow+=1
          v_red=0
        end
        if v_red==4||v_yellow==4
          @finished=true
        end
      end
    end
    for a in 0..$board_array_fill.size-1
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
    for a in 0..$board_array_fill.size-1
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


    for a in 0..$board_array_fill.size-1
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
    false
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
    game=Game.new
  end
end


on :mouse_down do |event|
  unless game.finished?
    game.coordinates_mouse(event.x,event.y)
  end
end

show
