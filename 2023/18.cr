require "./aoc"

AOC.day!(18)

enum Direction
  Right
  Down
  Left
  Up

  def self.new(s)
    case s
    when "U" then Up
    when "D" then Down
    when "L" then Left
    when "R" then Right
    else          raise "not a valid direction: #{s}"
    end
  end

  def turn_right
    self.class.new((self.value + 1) % 4)
  end

  def turn_left
    self.class.new((self.value - 1) % 4)
  end
end

instructions_pt1 = [] of {Direction, Int32}
instructions_pt2 = [] of {Direction, Int32}

instructions = AOC.lines.map do |line|
  line.match!(/(\w) (\d+) \(#(.....)(\d)\)/)

  dir = Direction.new($~[1])
  len = $~[2].to_i
  instructions_pt1 << {dir, len}

  len_pt2 = $~[3].to_i(base: 16)
  dir_pt2 = Direction.new($~[4].to_i)
  instructions_pt2 << {dir_pt2, len_pt2}
end

# Note: we assume the puzzle input travels clockwise around the lagoon and does
# not intersect itself.

def build_coordinates(instructions)
  start = {0, 0}
  coords = [start]

  instructions.each_with_index do |(dir, len), i|
    x, y = coords.last

    prev_dir = instructions[i - 1][0]
    next_dir = instructions[(i + 1) % instructions.size][0]

    # To account for the lagoon trench being one meter wide:
    if prev_dir.turn_right == dir
      # Taking an "outside" turn to the right increases the distance by one.
      len += 1
    end
    if dir.turn_left == next_dir
      # If the next turn is an "inside" turn to the left, decrease the distance by one.
      len -= 1
    end

    new_coord = case dir
                in .up?    then {x, y + len}
                in .down?  then {x, y - len}
                in .left?  then {x - len, y}
                in .right? then {x + len, y}
                end

    coords << new_coord
  end

  coords
end

# Base on https://www.mathopenref.com/coordpolygonarea2.html
def measure_area(coords)
  area = 0i64
  coords.each_cons_pair do |a, b|
    area += (b[0] - a[0]).to_i64 * (b[1] + a[1])
  end
  area // 2
end

AOC.part1 do
  measure_area(build_coordinates(instructions_pt1))
end

AOC.part2 do
  measure_area(build_coordinates(instructions_pt2))
end
