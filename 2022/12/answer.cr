require "../aoc"

AOC.day!(12)

# To simplify Part 2, we solve both parts "backwards" by going from E to S

class Node
  property height : Int32
  property distance : Int32 = Int32::MAX

  property reachable = [] of {Int32, Node}

  property goal = false

  def initialize(map_char)
    case map_char
    when 'a'..'z'
      @height = map_char - 'a'
    when 'S'
      @height = 0
      @goal = true
    when 'E'
      @height = 25
      @distance = 0
    else
      raise "bad input character #{map_char}"
    end
  end
end

nodes = AOC.lines.map do |line|
  line.chars.map { |c| Node.new(c) }
end

(0...nodes.size).each do |row|
  (0...nodes[row].size).each do |col|
    node = nodes[row][col]

    neighbors = [] of Node
    neighbors << nodes[row][col - 1] if col > 0
    neighbors << nodes[row][col + 1] if col < nodes[row].size - 1
    neighbors << nodes[row - 1][col] if row > 0
    neighbors << nodes[row + 1][col] if row < nodes.size - 1

    node.reachable = neighbors
      .select { |neighbor|
        # going backwards, so we can step down by at most 1 at a time
        node.height - neighbor.height <= 1
      }
      # weight is always 1
      .map { |n| {1, n} }
  end
end

nodes = nodes.flatten

def distance_to_goal(nodes)
  unvisited = nodes.sort_by(&.distance)

  until unvisited.first.goal
    current_node = unvisited.shift
    current_node.reachable.each do |weight, node|
      node.distance = Math.min(node.distance, current_node.distance + weight)
    end

    # this would be much more efficient if we used a heap
    unvisited.unstable_sort_by!(&.distance)
  end

  unvisited.first.distance
end

AOC.part1 do
  distance_to_goal(nodes)
end

AOC.part2 do
  # reset and change goal conditions
  nodes.each do |node|
    node.distance = Int32::MAX if node.distance > 0
    node.goal = node.height == 0
  end

  distance_to_goal(nodes)
end
