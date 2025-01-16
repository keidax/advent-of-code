require_relative "aoc"

def complete_subgraphs(graph, n)
  # copy the graph so we can mutate it
  graph = graph.to_h { [_1, _2.dup] }

  subgraphs = []

  keys = graph.keys
  keys.each do |key|
    graph[key].to_a.combination(n - 1).each do |neighbors|
      subgraphs << [key, *neighbors].to_set if all_connected?(graph, neighbors)
    end

    remove_node(graph, key)
  end

  subgraphs
end

def all_connected?(graph, nodes)
  return true if nodes.size < 2

  prime_node, *rest = nodes
  return false unless rest.all? { graph[prime_node].include?(_1) }

  all_connected?(graph, rest)
end

def remove_node(graph, node)
  neighbors = graph.delete(node)
  neighbors.each { graph[_1].delete(node) }
end

def extend_subgraph(graph, subgraph)
  extended = subgraph.dup
  neighbors = graph[subgraph.first]

  neighbors.each do |neighbor|
    if extended <= graph[neighbor]
      # neighbor connects to all other nodes in extended
      extended << neighbor
    end
  end

  extended
end

def find_largest_subgraph(graph, starting_subgraphs)
  current_max = Set.new

  starting_subgraphs.each do |subgraph|
    next if subgraph <= current_max

    extended = extend_subgraph(graph, subgraph)
    if extended.size > current_max.size
      current_max = extended
    end
  end

  current_max
end

graph = Hash.new { |h, k| h[k] = Set.new }

input = AOC.day(23)
input.lines(chomp: true).each do |line|
  a, b = line.split("-")
  graph[a] << b
  graph[b] << a
end

subgraphs_3 = complete_subgraphs(graph, 3)

AOC.part1 do
  subgraphs_3.count do |subgraph|
    subgraph.any? { _1.start_with?("t") }
  end
end

AOC.part2 do
  find_largest_subgraph(graph, subgraphs_3).sort.join(",")
end
