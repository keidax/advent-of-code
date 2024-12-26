require_relative "aoc"

def simulate_byte(grid, byte)
  row, col = byte
  grid[row][col] = "#"
end

def shortest_path(map, start, finish)
  distance = {}
  unvisited = []

  map.each do |pos, _|
    distance[pos] = Float::INFINITY
  end

  distance[start] = 0
  unvisited << start

  prev = {}

  while unvisited.size > 0
    pos = unvisited.shift
    dist = distance[pos]
    neighbors = map[pos]

    neighbors.each do |neighbor|
      if distance[neighbor] > dist + 1
        distance[neighbor] = dist + 1
        resort(unvisited, neighbor, distance)

        prev[neighbor] = [pos]
      elsif distance[neighbor] == dist + 1
        prev[neighbor] << pos
      end
    end

    break if pos == finish
  end

  [distance[finish], prev]
end

def resort(unvisited, pos, distance)
  new_dist = distance[pos]
  insert_idx = -1
  (0...unvisited.size).each do |i|
    if distance[unvisited[i]] >= new_dist
      insert_idx = i
      break
    end
  end

  if insert_idx == -1
    insert_idx = unvisited.size
  end
  unvisited.insert(insert_idx, pos)

  old_idx = unvisited.rindex(pos)
  if old_idx > insert_idx
    unvisited.delete_at(old_idx)
  end
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
    next unless path.include?(byte)

    # recalc path
    map = build_map(grid)
    distance, prev = shortest_path(map, start, finish)

    if distance == Float::INFINITY
      row, col = byte
      break "#{col},#{row}"
    end

    path = build_path(prev, finish)
  end
end
