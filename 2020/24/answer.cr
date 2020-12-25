require "string_scanner"

lines = File.read_lines("input.txt")

def simulate(input, days) : Int32
  max_size = input.map(&.size).max + days
  grid = Array.new(max_size * 2) { Array.new(max_size * 2) { false } }

  origin = {max_size, max_size}
  input.each do |line|
    x, y = origin
    ss = StringScanner.new(line)
    until ss.eos?
      case ss.scan(/e|w|ne|nw|se|sw/)
      when "e"
        x += 1
      when "w"
        x -= 1
      when "ne"
        x += 1
        y -= 1
      when "nw"
        y -= 1
      when "se"
        y += 1
      when "sw"
        x -= 1
        y += 1
      end
    end

    grid[y][x] = !grid[y][x]
  end

  days.times do
    new_grid = grid.clone
    each_tile(grid) do |x, y, adjacent|
      if grid[y][x]
        if adjacent == 0 || adjacent > 2
          new_grid[y][x] = false
        end
      else
        if adjacent == 2
          new_grid[y][x] = true
        end
      end
    end

    grid = new_grid
  end

  grid.sum { |line| line.count &.itself }
end

OFFSETS = [
  {+1, 0},
  {-1, 0},
  {+1, -1},
  {0, -1},
  {0, +1},
  {-1, +1},
]

def each_tile(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |tile, x|
      adjacent = 0
      OFFSETS.each do |x_off, y_off|
        x_n = x + x_off
        y_n = y + y_off

        if 0 <= x_n && x_n < row.size &&
           0 <= y_n && y_n < grid.size
          adjacent += 1 if grid[y_n][x_n]
        end
      end

      yield x, y, adjacent
    end
  end
end

# Part 1
puts simulate(lines, 0)
# Part 2
puts simulate(lines, 100)
