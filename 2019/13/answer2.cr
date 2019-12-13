require "../intcode"

enum Tile
  Empty  = 0
  Wall
  Block
  Paddle
  Ball

  def to_s
    case self
    when Wall   then "#"
    when Block  then "*"
    when Paddle then "="
    when Ball   then "@"
    else             " "
    end
  end
end

def show_score(score)
  printf "\e[0;0H"
  puts "----------|                 |---------"
  printf "\e[0;18H"
  printf score.to_s
end

input = File.read("input.txt").chomp
input = input.sub(0, '2') # Insert two quarters :D

joystick = Channel(Int64).new
output = Channel(Int64).new

prog = Intcode.new(input, input: joystick, output: output)
prog.run

printf "\e[?25l" # hide cursor
printf "\e[2J"   # clear screen

score = 0
show_score(0)

# Play the game manually
# spawn do
#   STDIN.raw!

#   loop do
#     key_in = STDIN.gets(' ', limit: 3)
#     case key_in
#     when "\e[D"
#       joystick.send -1
#     when "\e[C"
#       joystick.send 1
#     else
#       joystick.send 0
#     end
#   end
# end

ball = Channel({Int64, Int64}).new(1)
paddle = Channel({Int64, Int64}).new(1)

spawn do
  # Wait for initial drawing
  paddle_pos = paddle.receive
  ball_pos = ball.receive

  loop do
    tilt = (ball_pos[0] <=> paddle_pos[0]).to_i64
    prog.input.send tilt

    # Paddle only gets redrawn if it moved
    paddle_pos = paddle.receive unless tilt == 0
    ball_pos = ball.receive
  end
end

loop do
  x, y, id = output.receive, output.receive, output.receive

  if x == -1 && y == 0
    score = id
    show_score score
  else
    tile = Tile.new(id.to_i32)
    printf "\e[#{y + 2};#{x + 1}H#{tile}"

    # Update game state
    if tile == Tile::Paddle
      paddle.send({x, y})
    elsif tile == Tile::Ball
      ball.send({x, y})
    end
  end
rescue Channel::ClosedError
  break
end

printf "\e[25H"
puts "GAME OVER!"
puts "score: #{score}"

# Reset terminal state
printf "\e[?25h" # show cursor
STDIN.cooked!
