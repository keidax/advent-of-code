require "../expect"

expect "Example 1", <<-EX, 8
#########
#b.A.@.a#
#########
EX

expect "Example 2", <<-EX, 86
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
EX

expect "Example 3", <<-EX, 132
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################
EX

expect "Example 4", <<-EX, 136
#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################
EX

expect "Example 5", <<-EX, 81
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################
EX

expect "test 1", <<-TEST, 7
#####
##b##
#a@d#
##c##
#####
TEST

expect "test 2", <<-TEST, 12
#######
###c###
#.....#
#a#@#b#
#######
TEST

expect "test 3", <<-TEST, 2
#####
##..#
#a.@#
#####
TEST

expect "test 4", <<-TEST, 9
######
#a..d#
#.@..#
#b..c#
######
TEST

# ENV["VERBOSE"] = "yes"
puts answer File.read("input.txt")

struct Char
  def open?
    self == '.'
  end
end

alias Map = Array(Array(Char))

class Node
  property x : Int32, y : Int32
  property! key : Char?, door : Char?
  property? start : Bool

  def initialize(@x, @y, @key = nil, @door = nil, @start = false)
  end

  def intersection?
    !(key? || door? || start?)
  end

  def to_s(io)
    io << "#<Node: #{x.colorize(:blue)},#{y.colorize(:blue)} "
    if key?
      io << key.colorize(:green).bold
    elsif door?
      io << door.colorize(:red)
    elsif start?
      io << '@'.colorize(:magenta)
    else
      io << '+'.colorize(:red)
    end
    io << ">"
  end

  def inspect(io)
    to_s(io)
  end

  def_equals_and_hash x, y
end

alias Graph = Hash(Node, Hash(Node, Int32))

def build_map(input : String) : Map
  map = Map.new

  input.each_line do |line|
    map << line.chars
  end

  map
end

alias Neighbor = {x: Int32, y: Int32, char: Char}

def neighbors(map, x, y, prev_x, prev_y) : Array(Neighbor)
  directions = [
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0},
  ]

  neighbors = [] of Neighbor

  directions.each do |x_off, y_off|
    n_x = x + x_off
    n_y = y + y_off

    next if n_y < 0 || n_y >= map.size
    next if n_x < 0 || n_x >= map[0].size
    next if n_x == prev_x && n_y == prev_y

    char = map[n_y][n_x]
    next if char == '#'

    neighbors << {x: n_x, y: n_y, char: char}
  end

  neighbors
end

def build_graph(map : Map) : Graph
  graph = Graph.new do |graph, node|
    graph[node] = Hash(Node, Int32).new
  end

  start_pos = {-1, -1}
  map.each_with_index do |row, y|
    row.each_with_index do |char, x|
      if char == '@'
        start_pos = {x, y}
        break
      end
    end
  end

  start_node = Node.new(*start_pos, start: true)
  graph[start_node]

  mapping_stack = Deque({x: Int32, y: Int32, from: Node}).new

  neighbors(map, start_node.x, start_node.y, -1, -1).each do |neighbor|
    mapping_stack << {x: neighbor[:x], y: neighbor[:y], from: start_node}
  end

  until mapping_stack.empty?
    next_edge = mapping_stack.pop
    when_verbose do
      puts "checking from #{next_edge}"
      pp mapping_stack
    end
    from = next_edge[:from]

    steps = 1
    next_x, next_y = next_edge[:x], next_edge[:y]
    prev_x, prev_y = from.x, from.y

    # It's possible we hit an interesting node right away
    start_char = map[next_y][next_x]
    if start_char != '.'
      add_new_node(map, graph, mapping_stack, next_x, next_y, start_char, steps, prev_x, prev_y, from)
      next
    end

    # ..or an adjacent intersection
    if neighbors(map, next_x, next_y, prev_x, prev_y).size > 1
      add_new_node(map, graph, mapping_stack, next_x, next_y, start_char, steps, prev_x, prev_y, from)
      next
    end

    neighbors = [] of Neighbor
    loop do
      steps += 1

      neighbors = neighbors(map, next_x, next_y, prev_x, prev_y)
      break unless neighbors.one?

      neighbor = neighbors.first
      break unless neighbor[:char].open?

      prev_x, prev_y = next_x, next_y
      next_x, next_y = neighbor[:x], neighbor[:y]
    end

    if neighbors.none?
      when_verbose { puts "no neighbors" }
      # We've reached a dead end
      next
    end

    if neighbors.one?
      # We've reached an interesting node
      neighbor = neighbors.first
      add_new_node(map, graph, mapping_stack, neighbor[:x], neighbor[:y], neighbor[:char], steps, next_x, next_y, from)
    else
      # We've reached an intersection
      steps -= 1
      add_new_node(map, graph, mapping_stack, next_x, next_y, map[next_y][next_x], steps, prev_x, prev_y, from)
    end
  end

  graph
end

def add_new_node(map, graph, stack, x, y, char, steps, prev_x, prev_y, prev_node)
  new_node = if char.ascii_uppercase?
               Node.new(x, y, door: char)
             elsif char.ascii_lowercase?
               Node.new(x, y, key: char)
             elsif char == '@'
               Node.new(x, y, start: true)
             else
               Node.new(x, y)
             end

  already_exists = graph.has_key?(new_node)

  # Make sure we choose the most efficient edge
  if already_exists
    all_steps = [steps] of Int32 | Nil
    all_steps << graph[new_node][prev_node]?
    all_steps << graph[prev_node][new_node]?
    steps = all_steps.compact.min.not_nil!
  end

  graph[new_node][prev_node] = steps
  graph[prev_node][new_node] = steps

  if already_exists
    when_verbose do
      puts "already added node #{new_node}"
      puts
    end

    return
  end

  when_verbose do
    puts "new node is #{new_node}"
    puts
  end

  neighbors(map, x, y, prev_x, prev_y).each do |neighbor|
    stack << {x: neighbor[:x], y: neighbor[:y], from: new_node}
  end
end

# Trim or combine unnecessary nodes.
# Returns the number of nodes that were removed.
def simplify(graph, already_changed = 0) : Int32
  count = 0
  graph.each do |node, connected|
    # Remove leaf intersections
    if node.intersection? && connected.size == 1
      graph.delete(node)
      graph[connected.first[0]].delete(node)

      count += 1
    end

    # Reduce chained intersections
    if node.intersection? && connected.size == 2
      graph.delete(node)

      end1, end2 = connected.first_key, connected.last_key
      distance = connected.values.sum

      graph[end1].delete(node)
      graph[end1][end2] = distance

      graph[end2].delete(node)
      graph[end2][end1] = distance

      count += 1
    end
  end

  if count > 0
    return simplify(graph, already_changed + count)
  else
    return already_changed
  end
end

def solve_graph(graph) : Int32
  distance = 0
  keys = Set(Char).new
  all_keys = graph.keys.compact_map(&.key?).to_set
  cur_node = graph.keys.find(&.start?).not_nil!

  while keys.proper_subset?(all_keys)
    reachable = reachable_keys(graph, cur_node, have: keys)

    # TODO do better than selecting the first
    reachable_key, key_distance = reachable.first

    cur_node = reachable_key
    distance += key_distance
    keys << reachable_key.key
  end

  distance
end

# Return reachable nodes with keys, and their respective distance
def reachable_keys(graph, cur_node, have keys : Enumerable(Char)) : Hash(Node, Int32)
  searched_nodes = Set(Node).new << cur_node
  potential_nodes = Deque(Node).new
  reachable = Hash(Node, Int32).new

  potential_nodes.concat graph[cur_node].keys

  while potential_nodes.any?
    next_node = potential_nodes.shift
    next if searched_nodes.includes? next_node

    searched_nodes << next_node

    if next_node.door?
      lock = next_node.door.downcase
      next unless keys.includes? lock
    end

    if next_node.key? && !keys.includes?(next_node.key)
      reachable[next_node] = distance(graph, cur_node, next_node)
    end

    # Continue searching outward
    potential_nodes.concat graph[next_node].keys
  end

  reachable
end

DIST_CACHE = Graph.new do |graph, node|
  graph[node] = Hash(Node, Int32).new
end

def distance(graph, node1, node2) : Int32
  dist = DIST_CACHE[node1][node2]?
  return dist if dist

  dist = graph[node1][node2]?
  if dist
    DIST_CACHE[node1][node2] = dist
    return dist
  end

  dist_hash = distance_search(graph, node1)
  DIST_CACHE[node1] = dist_hash

  dist_hash[node2]
end

class NodeSearch
  include Comparable(self)

  property node : Node, distance = 999_999
  property? visited = false

  def initialize(@node)
  end

  def <=>(other : self)
    distance <=> other.distance
  end

  def set_distance(distance)
    return if visited?

    if distance < @distance
      @distance = distance
    end
  end
end

# Implement Dijkstra's algorithm to get the shortest distance to all other nodes
def distance_search(graph, node) : Hash(Node, Int32)
  visited = Hash(Node, Int32).new
  unvisited = Array(NodeSearch).new
  lookup = Hash(Node, NodeSearch).new

  graph.each_key do |key_node|
    node_search = NodeSearch.new(key_node)
    unvisited << node_search
    lookup[key_node] = node_search
  end

  lookup[node].set_distance(0)

  while unvisited.any?
    unvisited.sort!
    cur_node = unvisited.shift
    cur_dist = cur_node.distance

    graph[cur_node.node].each do |next_key, next_dist|
      lookup[next_key].set_distance(cur_dist + next_dist)
    end

    cur_node.visited = true
    visited[cur_node.node] = cur_dist
  end

  visited.delete(node)
  visited
end

def answer(input) : Int32
  map = build_map(input)
  graph = build_graph(map)
  when_verbose do
    simplify_count = simplify(graph)
    pp graph
    puts graph.size
    puts "simplified by #{simplify_count}"
  end

  solve_graph(graph)
end
