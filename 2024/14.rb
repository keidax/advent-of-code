require_relative "aoc"

input = AOC.day(14)

class Robot
  X_BOUND = 101
  Y_BOUND = 103

  attr_accessor :position_x, :position_y
  attr_accessor :velocity_x, :velocity_y
  def initialize(line)
    line =~ /p=(.*),(.*) v=(.*),(.*)/

    @position_x = $1.to_i
    @position_y = $2.to_i
    @velocity_x = $3.to_i
    @velocity_y = $4.to_i
  end

  def advance(seconds)
    self.position_x = (position_x + velocity_x * seconds) % X_BOUND
    self.position_y = (position_y + velocity_y * seconds) % Y_BOUND
  end

  def quadrant
    mid_x = X_BOUND / 2
    mid_y = Y_BOUND / 2

    if position_x == mid_x || position_y == mid_y
      # exactly in the middle
      return nil
    end

    if position_x < mid_x
      if position_y < mid_y
        :top_left
      else
        :bottom_left
      end
    elsif position_y < mid_y
      :top_right
    else
      :bottom_right
    end
  end
end

def max_horizontal_line(robots)
  # it's much faster to sort integers directly, so map the position into an integer
  cols = robots.map { _1.position_y * 1000 + _1.position_x }
  cols.sort!
  max_consecutive(cols)
end

def max_per_row(robots)
  robots.map(&:position_y).tally.values.max
end

def max_consecutive(array)
  max_cons = 0
  cons = 1
  prev = array.first - 2

  array.each do |x|
    if prev + 1 == x
      cons += 1
    else
      max_cons = cons if cons > max_cons
      cons = 1
    end
    prev = x
  end

  max_cons = cons if cons > max_cons
  max_cons
end

robots = input.lines(chomp: true).map { Robot.new _1 }

AOC.part1 do
  robots.each { _1.advance(100) }

  robots.map(&:quadrant).compact
    .tally
    .values
    .reduce(:*)
end

robots.each { _1.advance(-100) }

# Based on some foreknowledge: the Christmas tree is bordered by a 31x33 square
SINGLE_ROW_HEURISTIC = 30

# Every Y_BOUND seconds, each robot will return to the same row:
#   (position_y + velocity_y * Y_BOUND) % Y_BOUND == position_y
# So, the strategy is:
#  1. Advance time until a lot of robots are grouped in the same row. At this point, they are on
#     the same row as they'll be to form the final image, but their columns are all scrambled.
#  2. Step forward Y_BOUND seconds at a time. Each this happens, robots will return to the same row.
#  3. After each step, check to see if a lot of robots have formed an unbroken horizontal line. If
#     so, assume they have formed the Christmas tree image.
AOC.part2 do
  seconds = 0

  loop do
    robots.each { _1.advance(1) }
    seconds += 1

    if max_per_row(robots) >= SINGLE_ROW_HEURISTIC
      break
    end
  end

  while seconds < (Robot::X_BOUND * Robot::Y_BOUND)
    robots.each { _1.advance(Robot::Y_BOUND) }
    seconds += Robot::Y_BOUND

    if max_horizontal_line(robots) >= SINGLE_ROW_HEURISTIC
      break seconds
    end
  end
end
