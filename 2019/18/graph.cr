require "./grid"
require "./node"

class Graph
  @grid : Grid
  @data : Hash(Node, Hash(Node, Int32))
  delegate :size, to: @data

  def initialize(grid)
    start_location = grid.find('@')
    initialize(grid, start_location)
  end

  def initialize(grid, start_location)
    @grid = grid
    @data = Hash(Node, Hash(Node, Int32)).new do |data, node|
      data[node] = Hash(Node, Int32).new
    end

    start_node = Node.new(start_location[:x], start_location[:y], start: true)

    mapping_stack = Deque({x: Int32, y: Int32, from: Node}).new

    grid.neighbors(start_node.x, start_node.y).each do |neighbor|
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
      start_char = grid[x: next_x, y: next_y]
      if start_char != '.'
        add_new_node(mapping_stack, next_x, next_y, steps, prev_x, prev_y, from)
        next
      end

      # ..or an adjacent intersection
      if grid.neighbors(next_x, next_y, exclude: {x: prev_x, y: prev_y}).size > 1
        add_new_node(mapping_stack, next_x, next_y, steps, prev_x, prev_y, from)
        next
      end

      neighbors = [] of Grid::Neighbor
      loop do
        steps += 1

        neighbors = grid.neighbors(next_x, next_y, exclude: {x: prev_x, y: prev_y})
        break unless neighbors.one?

        neighbor = neighbors.first
        neighbor_char = @grid[**neighbor]
        break unless neighbor_char == '.'

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
        add_new_node(mapping_stack, neighbor[:x], neighbor[:y], steps, next_x, next_y, from)
      else
        # We've reached an intersection
        steps -= 1
        add_new_node(mapping_stack, next_x, next_y, steps, prev_x, prev_y, from)
      end
    end
  end

  def add_new_node(stack, x, y, steps, prev_x, prev_y, prev_node)
    char = @grid[x: x, y: y]

    new_node = if char.ascii_uppercase?
                 Node.new(x, y, door: char)
               elsif char.ascii_lowercase?
                 Node.new(x, y, key: char)
               elsif char == '@'
                 Node.new(x, y, start: true)
               else
                 Node.new(x, y)
               end

    already_exists = @data.has_key?(new_node)

    # Make sure we choose the most efficient edge
    if already_exists
      all_steps = [steps] of Int32 | Nil
      all_steps << @data[new_node][prev_node]?
      all_steps << @data[prev_node][new_node]?
      steps = all_steps.compact.min.not_nil!
    end

    @data[new_node][prev_node] = steps
    @data[prev_node][new_node] = steps

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

    @grid.neighbors(x, y, exclude: {x: prev_x, y: prev_y}).each do |neighbor|
      stack << {x: neighbor[:x], y: neighbor[:y], from: new_node}
    end
  end

  # Trim or combine unnecessary nodes.
  # Returns the number of nodes that were removed.
  def simplify!(already_changed = 0) : Int32
    change_count = 0
    @data.each do |node, connected|
      # Remove leaf intersections
      if node.intersection? && connected.size == 1
        @data.delete(node)
        @data[connected.first[0]].delete(node)

        change_count += 1
      end

      # Reduce chained intersections
      if node.intersection? && connected.size == 2
        @data.delete(node)

        end1, end2 = connected.first_key, connected.last_key
        distance = connected.values.sum

        @data[end1].delete(node)
        @data[end1][end2] = distance

        @data[end2].delete(node)
        @data[end2][end1] = distance

        change_count += 1
      end
    end

    if change_count > 0
      return simplify!(already_changed + change_count)
    else
      return already_changed
    end
  end

  # Returns all nodes.
  def nodes : Enumerable(Node)
    @data.keys
  end

  @all_keys : Set(Char)?

  # Returns all keys.
  def all_keys : Set(Char)
    @all_keys ||= @data.keys.compact_map(&.key?).to_set
  end

  # Returns reachable keys, and their respective distance.
  # _with_keys_ are the keys that have already been picked up.
  def keys_reachable_from(node : Node, with_keys, max_distance) : Hash(Node, Int32)
    searched_nodes = Set(Node).new << node
    potential_nodes = Deque(Node).new
    reachable = Hash(Node, Int32).new

    potential_nodes.concat @data[node].keys

    while potential_nodes.any?
      next_node = potential_nodes.shift
      next if searched_nodes.includes? next_node

      searched_nodes << next_node

      if next_node.door?
        lock = next_node.door.downcase
        next unless with_keys.includes? lock
      end

      if next_node.key? && !with_keys.includes?(next_node.key)
        distance_to_next = distance(node, next_node)
        if distance_to_next <= max_distance
          reachable[next_node] = distance_to_next
        else
          next
        end
      end

      # Continue searching outward
      potential_nodes.concat @data[next_node].keys
    end

    reachable
  end

  @distance_caches = Hash(Node, Hash(Node, Int32)).new

  # Returns the minimum distance between two nodes.
  def distance(node1, node2) : Int32
    if cache = @distance_caches[node1]?
      return cache[node2]
    end

    if cache = @distance_caches[node2]?
      return cache[node1]
    end

    dist_hash = distance_search(node1)
    @distance_caches[node1] = dist_hash

    dist_hash[node2]
  end

  private class NodeSearch
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

  # Implement Dijkstra's algorithm to get the shortest distance to all other nodes.
  private def distance_search(node) : Hash(Node, Int32)
    visited = Hash(Node, Int32).new
    unvisited = Array(NodeSearch).new
    lookup = Hash(Node, NodeSearch).new

    @data.each_key do |key_node|
      node_search = NodeSearch.new(key_node)
      unvisited << node_search
      lookup[key_node] = node_search
    end

    lookup[node].set_distance(0)

    while unvisited.any?
      unvisited.sort!
      cur_node = unvisited.shift
      cur_dist = cur_node.distance

      @data[cur_node.node].each do |next_key, next_dist|
        lookup[next_key].set_distance(cur_dist + next_dist)
      end

      cur_node.visited = true
      visited[cur_node.node] = cur_dist
    end

    visited.delete(node)
    visited
  end
end
