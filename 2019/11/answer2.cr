require "../intcode"

enum Color : Int64
  Black = 0
  White = 1
end

enum Direction
  Up    = 0
  Right = 1
  Down  = 2
  Left  = 3

  def to_right
    Direction.new (self.value + 1) % 4
  end

  def to_left
    Direction.new (self.value - 1) % 4
  end
end

# Track current color, and if the panel has ever been painted
struct Panel
  getter color : Color = Color::Black
  @painted = false

  def color=(color)
    @color = color
    @painted = true
  end

  def painted?
    @painted
  end

  def to_s(io)
    io << if color == Color::Black
      '.'
    else
      '#'
    end
  end
end

class Robot
  @program : Intcode
  @grid : Array(Array(Panel)) = Array.new(60) { Array.new(60) { Panel.new } }
  @position = {10, 30}
  @direction = Direction::Up

  def initialize(input)
    @program = Intcode.new(input)

    white_panel = Panel.new
    white_panel.color = Color::White

    @grid[@position[0]][@position[1]] = white_panel
  end

  def paint
    @program.run

    loop do
      x, y = @position
      current_panel = @grid[x][y]

      # Feed camera input
      @program.input.send(current_panel.color.value)

      paint_color = @program.output.receive
      current_panel.color = Color.new(paint_color)

      # Need to write panel back to grid
      @grid[x][y] = current_panel

      turn_direction = @program.output.receive
      @direction = if turn_direction == 0
                     @direction.to_left
                   else
                     @direction.to_right
                   end

      self.move_forward

      Fiber.yield

      break if @program.output.closed?
    end

    @grid.each do |row|
      puts row.join ""
    end
  end

  private def move_forward
    offset = case @direction
             when Direction::Up    then {0, 1}
             when Direction::Right then {1, 0}
             when Direction::Down  then {0, -1}
             when Direction::Left  then {-1, 0}
             else
               raise "unknown direction"
             end

    @position = {@position[0] + offset[0], @position[1] + offset[1]}
  end
end

program_input = File.read("input.txt").chomp
bot = Robot.new(program_input)
bot.paint
