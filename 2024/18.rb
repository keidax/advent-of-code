require_relative "aoc"

require "fast_containers"

def simulate_byte(grid, byte)
  row, col = byte
  grid[row][col] = "#"
end

def shortest_path(map, start, finish)
  # distance = {}
  distance = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, Float::INFINITY) }
  unvisited = FastContainers::PriorityQueue.new(:min)

  # map.each do |pos, _|
  #   distance[pos] = Float::INFINITY
  # end

  distance[start[0]][start[1]] = 0
  unvisited.push(start, 0)

  prev = {}

  while unvisited.size > 0
    priority_dist, pos = unvisited.top_key, unvisited.pop
    dist = distance[pos[0]][pos[1]]

    if priority_dist > dist
      # we already visited this coord
      next
    end

    neighbors = map[pos]

    neighbors.each do |neighbor|
      new_dist = dist + 1
      if distance[neighbor[0]][neighbor[1]] > new_dist
        distance[neighbor[0]][neighbor[1]] = new_dist
        unvisited.push(neighbor, new_dist)

        prev[neighbor] = [pos]
      elsif distance[neighbor[0]][neighbor[1]] == new_dist
        prev[neighbor] << pos
      end
    end

    break if pos == finish
  end

  [distance[finish[0]][finish[1]], prev]
end

def adjacent_spaces(pos, grid)
  row, col = pos
  adjacent = []

  [
    [row - 1, col],
    [row + 1, col],
    [row, col - 1],
    [row, col + 1]
  ].each do |adj|
    adj_row, adj_col = adj
    next if adj_row < 0
    next if adj_col < 0
    next if adj_row >= grid.size
    next if adj_col >= grid[adj_row].size
    next if grid[adj_row][adj_col] == "#"

    adjacent << adj
  end

  adjacent
end

def build_map(grid)
  map = {}

  grid.each_with_index do |chars, row|
    chars.each_with_index do |char, col|
      pos = case char
      when "#"
        next
      when "."
        [row, col]
      end

      map[pos] = adjacent_spaces(pos, grid)
    end
  end

  map
end

# GRID_SIZE = 7
# PART_1_BYTES = 12

GRID_SIZE = 71
PART_1_BYTES = 1024

input = AOC.day(18)
grid = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, ".") }

bytes = input.lines.map do |line|
  col, row = line.split(",").map(&:to_i)
  [row, col]
end
bytes[0...PART_1_BYTES].each { simulate_byte(grid, _1) }

start = [0, 0]
finish = [GRID_SIZE - 1, GRID_SIZE - 1]

map = build_map(grid)
distance, prev = shortest_path(map, start, finish)

AOC.part1 do
  distance
end

def build_path(prev, finish)
  path = Set.new
  cur = finish
  while cur
    path << cur
    cur = prev[cur]&.first
  end
  path
end

AOC.part2 do
  path = build_path(prev, finish)

  (PART_1_BYTES...bytes.size).each do |i|
    byte = bytes[i]
    simulate_byte(grid, byte)

    # patch the map to remove the new byte
    if map[byte]
      old_neighbors = map.delete(byte)
      old_neighbors.each do |neighbor|
        map[neighbor].delete(byte)
      end
    end

    next unless path.include?(byte)

    # recalc path
    distance, prev = shortest_path(map, start, finish)

    if distance == Float::INFINITY
      row, col = byte
      break "#{col},#{row}"
    end

    path = build_path(prev, finish)
  end
end
