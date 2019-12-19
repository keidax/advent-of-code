require "../intcode"

enum Direction : Int32
  # Use ASCII values of directional chars
  Up    =  94 # ^
  Right =  62 # >
  Down  = 118 # v
  Left  =  60 # <

  def turn(char) : self
    case char
    when 'L'
      case
      when left?
        Down
      when down?
        Right
      when right?
        Up
      when up?
        Left
      else raise "#{self} is not a valid direction!"
      end
    when 'R'
      case
      when left?
        Up
      when up?
        Right
      when right?
        Down
      when down?
        Left
      else raise "#{self} is not a valid direction!"
      end
    else raise "#{char} is not a valid turn!"
    end
  end
end

input = File.read("./input.txt").chomp
input = input.sub(0, '2') # Wake up the bot

# Computed by hand...
logic = <<-BOT
A,B,A,B,C,C,B,A,B,C
L,4,R,8,L,6,L,10
L,6,R,8,R,10,L,6,L,6
L,4,L,4,L,10
y

BOT

logic_input = logic.chars.map &.ord.to_i64

program = Intcode.new(input, logic_input)
program.run

row = 0
while row <= 39 # initial screen + prompt lines
  ch = program.output.receive.chr

  if ch == '\n'
    row += 1
  end

  print ch
end

printf "\e[2J"
printf "\e[0;0H"

# Handle live camera feed
# Buffer output in array
screen = [] of Char
row = 0
loop do
  ch = program.output.receive.chr

  unless ch.ascii?
    puts ch.ord
    exit 0
  end

  if ch == '\n'
    row += 1

    if row > 33
      row = 0
      printf "\e[1;1H"
      puts screen.join ""
      screen.clear

      next
    end
  end
  screen << ch
end

# ROWS = 33
# COLS = 37

# SCAFFOLD = Array.new(ROWS) { Array(Char).new(COLS) { ' ' } }

# row = 0
# col = 0

# bot_row, bot_col = 0, 0
# bot_dir : Direction? = nil
# loop do
#   ch = program.output.receive.chr
#   print ch

#   case ch
#   when '#', '.'
#     SCAFFOLD[row][col] = ch
#     col += 1
#   when '^', 'v', '<', '>'
#     SCAFFOLD[row][col] = '#'
#     bot_dir = Direction.new(ch.ord)
#     bot_row, bot_col = row, col
#     col += 1
#   when '\n'
#     row += 1
#     col = 0
#   else
#     raise "unknown char: #{ch}"
#   end
# rescue Channel::ClosedError
#   break
# end

# def find_turn(row, col, facing_dir) : Char
#   case facing_dir
#   when .up?
#     left_option, right_option = {row, col - 1}, {row, col + 1}
#   when .down?
#     left_option, right_option = {row, col + 1}, {row, col - 1}
#   when .left?
#     left_option, right_option = {row + 1, col}, {row - 1, col}
#   when .right?
#     left_option, right_option = {row - 1, col}, {row + 1, col}
#   else
#     raise "unknown direction!"
#   end

#   if position_valid?(*left_option)
#     'L'
#   elsif position_valid?(*right_option)
#     'R'
#   else
#     raise "no way to turn!"
#   end
# end

# def position_valid?(row, col)
#   return false if row < 0 || col < 0
#   return false if row >= ROWS || col >= COLS

#   SCAFFOLD[row][col] == '#'
# end

# def find_max_move(row, col, facing_dir) : {Int32, Int32, Int32}
#   row_off, col_off = case facing_dir
#                      when .left?  then {0, -1}
#                      when .right? then {0, +1}
#                      when .up?    then {-1, 0}
#                      when .down?  then {+1, 0}
#                      else
#                        raise "invalid direction"
#                      end

#   distance = 0

#   while position_valid?(row + row_off, col + col_off)
#     row += row_off
#     col += col_off
#     distance += 1
#   end

#   return distance, row, col
# end

# current_dir : Direction = bot_dir.not_nil!

# full_path = [] of Char | Int32

# loop do
#   # First turn the robot
#   turn = find_turn(bot_row, bot_col, current_dir)
#   full_path << turn
#   current_dir = current_dir.turn(turn)
#   # Then move straight
#   distance, bot_row, bot_col = find_max_move(bot_row, bot_col, current_dir)
#   full_path << distance
# rescue e
#   # catch "no way to turn!" at end of path
#   break
# end

# puts full_path
