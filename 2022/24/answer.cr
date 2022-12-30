require "../aoc"

AOC.day!(24)

enum Direction
  Up
  Down
  Left
  Right
end

class Blizzard
  @@map : Array(Array(Array(self))) = [] of Array(Array(self))

  class_property width = 0, height = 0

  def self.initialize_map!
    @@map = Array.new(@@height) { Array.new(@@width) { [] of self } }
  end

  def self.all
    @@map.flatten
  end

  def self.clear?(x, y)
    return false unless 0 <= y < @@height
    return false unless 0 <= x < @@width
    @@map[y][x].empty?
  end

  def self.next_minute!
    self.all.each(&.move)
  end

  @location : {Int32, Int32}
  @direction : Direction

  def initialize(@location, @direction)
    @@map[@location[1]][@location[0]] << self
  end

  def move
    x, y = @location
    @@map[y][x].delete(self)

    x, y = @location = next_location
    @@map[y][x] << self
  end

  private def next_location
    x, y = @location

    case @direction
    in Direction::Up
      y -= 1
    in Direction::Down
      y += 1
    in Direction::Left
      x -= 1
    in Direction::Right
      x += 1
    end

    x %= @@width
    y %= @@height

    {x, y}
  end

  def location
    @location
  end
end

Blizzard.width = (AOC.lines.first.size - 2)
Blizzard.height = (AOC.lines.size - 2)
Blizzard.initialize_map!

AOC.lines[1..-2].each_with_index do |line, y|
  line[1..-2].chars.each_with_index do |c, x|
    direction = case c
                when '^' then Direction::Up
                when 'v' then Direction::Down
                when '<' then Direction::Left
                when '>' then Direction::Right
                when '.' then nil
                else          raise "bad direction '#{c}'"
                end
    next unless direction
    Blizzard.new({x, y}, direction)
  end
end

def minutes_to_travel(start, goal)
  minutes = 0
  visited = Set({Int32, Int32}){start}

  loop do
    minutes += 1
    Blizzard.next_minute!

    new_locations = Set({Int32, Int32}){start}

    visited.each do |location|
      x, y = location

      if {x, y + 1} == goal || {x, y - 1} == goal
        return minutes
      end

      if Blizzard.clear?(x, y)
        new_locations << {x, y}
      end

      if x > 0 && Blizzard.clear?(x - 1, y)
        new_locations << {x - 1, y}
      end

      if x < Blizzard.width - 1 && Blizzard.clear?(x + 1, y)
        new_locations << {x + 1, y}
      end

      if y > 0 && Blizzard.clear?(x, y - 1)
        new_locations << {x, y - 1}
      end

      if y < Blizzard.height - 1 && Blizzard.clear?(x, y + 1)
        new_locations << {x, y + 1}
      end
    end

    visited = new_locations
  end
end

minutes = 0
start = {0, -1}
goal = {Blizzard.width - 1, Blizzard.height}

AOC.part1 do
  minutes = minutes_to_travel(start, goal)
end

AOC.part2 do
  minutes += minutes_to_travel(goal, start)
  minutes += minutes_to_travel(start, goal)
end
