require "bit_array"

def each_light(x1, y1, x2, y2)
  (x1..x2).each do |x|
    (y1..y2).each do |y|
      yield x, y
    end
  end
end

# Part 1
grid = Array.new(1000) { BitArray.new(1000) }

File.each_line("input.txt") do |line|
  coords = line.match(/(\d+),(\d+) through (\d+),(\d+)/).not_nil!.captures.compact
  operation = line.match(/(turn on|turn off|toggle)/).try &.[0]

  x1, y1, x2, y2 = {Int32, Int32, Int32, Int32}.from(coords.map(&.to_i32))

  each_light(x1, y1, x2, y2) do |x, y|
    case operation
    when "turn on"
      grid[x][y] = true
    when "turn off"
      grid[x][y] = false
    when "toggle"
      grid[x].toggle(y)
    else
      raise "unknown operation #{operation}"
    end
  end
end

puts grid.sum { |row| row.count(true) }

# Part 2
grid = Array.new(1000) { Array.new(1000, 0) }

File.each_line("input.txt") do |line|
  coords = line.match(/(\d+),(\d+) through (\d+),(\d+)/).not_nil!.captures.compact
  operation = line.match(/(turn on|turn off|toggle)/).try &.[0]

  x1, y1, x2, y2 = {Int32, Int32, Int32, Int32}.from(coords.map(&.to_i32))

  each_light(x1, y1, x2, y2) do |x, y|
    case operation
    when "turn on"
      grid[x][y] += 1
    when "turn off"
      grid[x][y] -= 1 if grid[x][y] > 0
    when "toggle"
      grid[x][y] += 2
    else
      raise "unknown operation #{operation}"
    end
  end
end

puts grid.sum &.sum
