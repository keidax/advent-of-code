require_relative "aoc"

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
  start = nil
  finish = nil

  grid.each_with_index do |chars, row|
    chars.each_with_index do |char, col|
      pos = case char
      when "#"
        next
      when "."
        [row, col]
      when "S"
        start = [row, col]
      when "E"
        finish = [row, col]
      end

      map[pos] = adjacent_spaces(pos, grid)
    end
  end

  [map, start, finish]
end

def split_to_grid(grid_lines)
  grid_lines.lines(chomp: true).map(&:chars)
end

def next_tile(map, coord)
  row, col, dir = coord

  edges = map[[row, col]]

  case dir
  when :up
    edges.find { _1[0] == row - 1 }
  when :down
    edges.find { _1[0] == row + 1 }
  when :left
    edges.find { _1[1] == col - 1 }
  when :right
    edges.find { _1[1] == col + 1 }
  else
    raise "bad direction"
  end
end

def left_turn(direction)
  case direction
  when :right then :up
  when :up then :left
  when :left then :down
  when :down then :right
  else raise "bad direction"
  end
end

def right_turn(direction)
  case direction
  when :right then :down
  when :down then :left
  when :left then :up
  when :up then :right
  else raise "bad direction"
  end
end

STEP_COST = 1
TURN_COST = 1000

def build_scores(map, start, finish)
  distance = {}
  directions = [:up, :down, :left, :right]
  unvisited = []

  map.each do |pos, _|
    directions.each do |dir|
      triple = [*pos, dir]

      distance[triple] = Float::INFINITY
    end
  end

  distance[[*start, :right]] = 0
  unvisited << [*start, :right]

  targets = [
    [*finish, :up],
    [*finish, :down],
    [*finish, :right],
    [*finish, :left]
  ]

  remaining_targets = targets.dup

  unvisited.sort_by! { distance[_1] }

  prev = {}

  while remaining_targets.size > 0
    coord = unvisited.shift
    dist = distance[coord]

    row, col, dir = coord

    if (next_pos = next_tile(map, coord))
      ahead_coord = [*next_pos, dir]
      if distance[ahead_coord] > (dist + STEP_COST)
        distance[ahead_coord] = dist + STEP_COST
        resort(unvisited, ahead_coord, distance)

        prev[ahead_coord] = [coord]
      elsif distance[ahead_coord] == (dist + STEP_COST)
        prev[ahead_coord] << coord
      end
    end

    right_coord = [row, col, right_turn(dir)]
    if distance[right_coord] > (dist + TURN_COST)
      distance[right_coord] = dist + TURN_COST
      resort(unvisited, right_coord, distance)

      prev[right_coord] = [coord]
    elsif distance[right_coord] == (dist + TURN_COST)
      prev[right_coord] << coord
    end

    left_coord = [row, col, left_turn(dir)]
    if distance[left_coord] > (dist + TURN_COST)
      distance[left_coord] = dist + TURN_COST
      resort(unvisited, left_coord, distance)

      prev[left_coord] = [coord]
    elsif distance[left_coord] == (dist + TURN_COST)
      prev[left_coord] << coord
    end

    remaining_targets.delete(coord)
  end

  [distance, prev]
end

# Using an array for unvisited is the bottleneck here -- ideally should
# be a min_heap
def resort(unvisited, coord, distance)
  new_dist = distance[coord]
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
  unvisited.insert(insert_idx, coord)

  old_idx = unvisited.rindex(coord)
  if old_idx > insert_idx
    unvisited.delete_at(old_idx)
  end
end

def count_path_size(start, finish, prev)
  queue = Set[finish]
  path = Set.new

  until queue.empty?
    coord = queue.first
    queue.delete(coord)
    path << [coord[0], coord[1]]

    if (next_coords = prev[coord])
      queue.merge(next_coords)
    end
  end

  path.size
end

input = AOC.day(16)

map, start, finish = input
  .then { split_to_grid(_1) }
  .then { build_map(_1) }

targets = [
  [*finish, :up],
  [*finish, :down],
  [*finish, :right],
  [*finish, :left]
]

distance, prev = build_scores(map, start, finish)

AOC.part1 do
  targets.map { distance[_1] }.min
end

AOC.part2 do
  min_target = targets.min_by { distance[_1] }

  count_path_size([*start, :right], min_target, prev)
end
