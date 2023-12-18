require "./aoc"
require "./min_heap"

AOC.day!(17)

enum Direction
  Right
  Down
  Left
  Up
end

alias Node = {Int32, Int32, Direction}

def add_to_graph(graph, costs, min_move, max_move, row, col)
  cost = 0
  to_left = (1..max_move).map do |i|
    new_col = col - i
    next if new_col < 0
    cost += costs[row][new_col]
    next if i < min_move

    { {row, new_col, Direction::Left}, cost }
  end.compact

  cost = 0
  to_right = (1..max_move).map do |i|
    new_col = col + i
    next if new_col >= costs[row].size
    cost += costs[row][new_col]
    next if i < min_move

    { {row, new_col, Direction::Right}, cost }
  end.compact

  cost = 0
  to_up = (1..max_move).map do |i|
    new_row = row - i
    next if new_row < 0

    cost += costs[new_row][col]
    next if i < min_move

    { {new_row, col, Direction::Up}, cost }
  end.compact

  cost = 0
  to_down = (1..max_move).map do |i|
    new_row = row + i
    next if new_row >= costs.size

    cost += costs[new_row][col]
    next if i < min_move

    { {new_row, col, Direction::Down}, cost }
  end.compact

  left_node = {row, col, Direction::Left}
  right_node = {row, col, Direction::Right}
  up_node = {row, col, Direction::Up}
  down_node = {row, col, Direction::Down}

  left_right = to_left.concat(to_right)
  up_down = to_up.concat(to_down)

  graph[left_node] = up_down
  graph[right_node] = up_down
  graph[up_node] = left_right
  graph[down_node] = left_right
end

tile_costs = AOC.lines.map do |line|
  line.chars.map(&.to_i)
end

def build_graph(tile_costs, crucible_range)
  graph_capacity = tile_costs.size * tile_costs[0].size * 4

  graph = Hash(Node, Array({Node, Int32})).new(initial_capacity: graph_capacity)
  (0...tile_costs.size).each do |row|
    (0...tile_costs[row].size).each do |col|
      add_to_graph(graph, tile_costs, crucible_range.begin, crucible_range.end, row, col)
    end
  end

  graph
end

def crucible_path(tile_costs, crucible_range)
  graph = build_graph(tile_costs, crucible_range)

  unvisited = MinHeap(Node).new

  unvisited
    .insert({0, 0, Direction::Right}, 0)
    .insert({0, 0, Direction::Down}, 0)

  visited = {} of Node => Int32

  max_row = tile_costs.size - 1
  max_col = tile_costs[max_row].size - 1
  target_right = {max_row, max_col, Direction::Right}
  target_down = {max_row, max_col, Direction::Down}

  val = 0

  loop do
    cur_node, cur_cost = unvisited.shift

    graph[cur_node].each do |(next_node, cost)|
      next if visited[next_node]?

      existing_cost = unvisited.value?(next_node)
      new_cost = cur_cost + cost
      if existing_cost
        if new_cost < existing_cost
          unvisited.update(next_node, new_cost)
        end
      else
        unvisited.insert(next_node, new_cost)
      end
    end

    visited[cur_node] = cur_cost

    if (cur_node == target_right && visited[target_down]?) ||
       (cur_node == target_down && visited[target_right]?)
      val = Math.min(visited[target_right], visited[target_down])
      break
    end
  end

  val
end

AOC.part1 do
  crucible_path(tile_costs, 1..3)
end

AOC.part2 do
  crucible_path(tile_costs, 4..10)
end
