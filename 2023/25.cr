require "./aoc"
require "./min_heap"

AOC.day!(25)

graph = Hash(String, Set(String)).new do |h, k|
  h[k] = Set(String).new
end

AOC.lines.each do |line|
  comp, links = line.split(": ")

  links.split(" ").each do |link|
    graph[comp] << link
    graph[link] << comp
  end
end

AOC.part1 do
  delete_best_link(graph, 100)
  delete_best_link(graph, 100)
  a, b = delete_best_link(graph, 100)

  a_con = connected(graph, a).size
  b_con = connected(graph, b).size

  a_con * b_con
end

# Basic idea: pick pairs of points at random and find the shortest path between them. If
# the points are in different subgraphs, then the shortest path will include one of the
# links we need to cut. Count up the frequency of all the links found, and delete the most
# common link.
#
# The input for this problem seems to consist of 2 subgraphs of roughly equal size, so
# this works pretty well. The more unequal their sizes, the smaller the odds of this
# algorithm succeeding.
def delete_best_link(graph, iterations)
  short_paths = [] of {String, String}
  iterations.times do
    start, finish = graph.keys.sample(2)
    min_path = minimum_path(graph, start, finish)
    min_path.each_cons(2) do |pair|
      path_step = Tuple(String, String).from(pair.sort)
      short_paths << path_step
    end
  end

  link = short_paths.tally.to_a.sort_by(&.[1]).last[0]
  puts "deleting #{link}"
  delete_link(graph, *link)

  link
end

def delete_link(graph, a, b)
  graph[a].delete(b)
  graph[b].delete(a)
end

def connected(graph, start)
  visited = Set(String).new
  unvisited = Deque(String).new

  visited << start
  unvisited.concat(graph[start])

  until unvisited.empty?
    next_node = unvisited.shift
    next if visited.includes?(next_node)

    unvisited.concat(graph[next_node])
    visited << next_node
  end

  visited
end

# Djikstra's algorithm, returning a list of all nodes on the shortest path instead of the distance
def minimum_path(graph, start, finish)
  visited = {} of String => Array(String)
  visited[start] = [start]

  unvisited = MinHeap(String).new
  graph[start].each do |next_node|
    unvisited.insert(next_node, 1)
  end

  loop do
    cur_node, cur_dist = unvisited.shift

    short_path : Array(String)? = nil

    graph[cur_node].each do |next_node|
      if (prev_path = visited[next_node]?)
        # Pick an adjacent visited path with the same size as our current distance
        if prev_path.size == cur_dist
          short_path ||= prev_path + [cur_node]
        end
        next
      end

      existing_dist = unvisited.value?(next_node)
      new_dist = cur_dist + 1

      if existing_dist
        if new_dist < existing_dist
          unvisited.update(next_node, new_dist)
        end
      else
        unvisited.insert(next_node, new_dist)
      end
    end

    if short_path
      visited[cur_node] = short_path
    else
      puts "warning: don't have a path for #{cur_node}"
      visited[cur_node] = [cur_node]
    end

    if cur_node == finish
      break
    end
  end

  visited[finish]
end
