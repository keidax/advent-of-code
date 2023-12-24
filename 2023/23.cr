require "./aoc"

AOC.day!(23)

alias Tile = {row: Int32, col: Int32}

def next_tile(prev, curr, grid)
  tiles = [] of Tile
  row = curr[:row]
  col = curr[:col]

  {
    {0, 1, '<'},
    {1, 0, '^'},
    {0, -1, '>'},
    {-1, 0, 'v'},
  }.each do |r_off, c_off, up_slope|
    n_row = row + r_off
    n_col = col + c_off
    next if n_row < 0 || n_row >= grid.size

    _next = {row: n_row, col: n_col}
    next if _next == prev

    char = grid[n_row][n_col]
    next if char == '#'
    next if char == up_slope

    return {char, _next}
  end

  nil
end

def build_segment(grid, start) : {Int32, Tile}
  length = 0

  prev, curr = start, start
  prev_char = '.'

  loop do
    if (next_info = next_tile(prev, curr, grid))
      char, _next = next_info

      prev = curr
      curr = _next
      length += 1

      if prev_char != '.'
        # we moved down a slope into an intersection
        break
      end

      prev_char = char
    else
      # next_tile is nil, end of segment
      break
    end
  end

  return {length, curr}
end

def build_intersection(grid, start) : Array(Tile)
  tiles = [] of Tile

  row = start[:row]
  col = start[:col]

  {
    {0, 1, '>'},
    {1, 0, 'v'},
    {0, -1, '<'},
    {-1, 0, '^'},
  }.each do |r_off, c_off, down_slope|
    n_row = row + r_off
    n_col = col + c_off

    if grid[n_row][n_col] == down_slope
      slope = {row: n_row, col: n_col}
      _, _next = next_tile(prev: start, curr: slope, grid: grid).not_nil!

      tiles << _next
    end
  end

  tiles
end

def build_graph(grid)
  target_row = grid.size - 1
  target_col = grid[target_row].size - 2

  start = {row: 0, col: 1}
  target = {row: target_row, col: target_col}

  graph = {} of Tile => {Int32, Array(Tile)}

  segment_beginnings = [start] of Tile
  intersections = [] of Tile

  until segment_beginnings.empty? && intersections.empty?
    if segment_beginnings.any?
      start = segment_beginnings.shift
      if graph.has_key?(start)
        next
      end

      length, _end = build_segment(grid, start)

      graph[start] = {length, [_end]}

      if _end == target
        # do nothing
      else
        intersections << _end
      end
    else
      intersection = intersections.shift
      if graph.has_key?(intersection)
        next
      end

      new_starts = build_intersection(grid, intersection)

      graph[intersection] = {2, new_starts}
      segment_beginnings.concat(new_starts)
    end
  end

  {graph, target}
end

def find_longest_path_pt1(graph, target)
  start = {row: 0, col: 1}
  dist = 0

  find_longest_path_pt1(graph, start, target, dist)
end

def find_longest_path_pt1(graph, start, target, distance)
  if start == target
    return distance
  end

  next_dist, next_tiles = graph[start]
  distance += next_dist

  next_tiles.max_of do |next_tile|
    find_longest_path_pt1(graph, next_tile, target, distance)
  end
end

def build_undirected_graph(graph)
  new_graph = Hash(Tile, Hash(Tile, Int32)).new do |h, k|
    h[k] = {} of Tile => Int32
  end

  graph.each do |tile, (dist, next_tiles)|
    next_tiles.each do |next_tile|
      new_graph[tile][next_tile] = dist
      new_graph[next_tile][tile] = dist
    end
  end

  new_graph
end

def find_longest_path_pt2(graph, target)
  start = {row: 0, col: 1}
  dist = 0

  find_longest_path_pt2(graph, start, target, dist)
end

def find_longest_path_pt2(graph, start, target, distance)
  if start == target
    return distance
  end

  next_tiles = graph[start]

  if next_tiles.size == 0
    return 0
  elsif next_tiles.size == 1
    graph.delete(start)
    graph[next_tiles.first[0]].delete(start)
  else
    graph = graph.clone
    graph.reject!(start)
    next_tiles.each do |next_tile, _|
      graph[next_tile].delete(start)
    end
  end

  next_tiles.max_of do |next_tile, next_dist|
    find_longest_path_pt2(graph, next_tile, target, distance + next_dist)
  end
end

grid = AOC.lines.map(&.chars)

AOC.part1 do
  graph, target = build_graph(grid)
  find_longest_path_pt1(graph, target)
end

AOC.part2 do
  graph, target = build_graph(grid)
  graph = build_undirected_graph(graph)

  # This is inefficient, but finishes in about 1 minute
  find_longest_path_pt2(graph, target)
end
