require "../expect"

require "./graph"
require "./grid"
require "./node"

expect "Example 1", {<<-EX}, 8
#########
#b.A.@.a#
#########
EX

expect "Example 2", {<<-EX}, 86
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
EX

expect "Example 3", {<<-EX}, 132
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################
EX

expect "Example 4", {<<-EX}, 136
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

expect "Example 5", {<<-EX}, 81
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################
EX

expect "test 1", {<<-TEST}, 7
#####
##b##
#a@d#
##c##
#####
TEST

expect "test 2", {<<-TEST}, 12
#######
###c###
#.....#
#a#@#b#
#######
TEST

expect "test 3", {<<-TEST}, 2
#####
##..#
#a.@#
#####
TEST

expect "test 4", {<<-TEST}, 9
######
#a..d#
#.@..#
#b..c#
######
TEST

expect "test 5", {<<-EX}, 68
#################
#...c......e....#
########@########
#k.E..a...g..A.n#
########.########
#l.D..d...h..C.m#
#################
EX

# ENV["VERBOSE"] = "yes"
puts answer File.read("input.txt")

class GraphState
  property(
    graph : Graph,
    current_node : Node,
    held_keys : Set(Char),
    distance_stepped : Int32,
  )

  # Map keys + position to how many steps it took to reach that place
  @@distance_cache = Hash(Set(Char), Hash(Node, Int32)).new
  @@global_min : Int32 = -1

  # Creates a new GraphState representing the start state.
  def initialize(@graph)
    @@distance_cache.clear
    @@global_min = 999_999_999

    @current_node = @graph.nodes.find(&.start?).not_nil!
    @held_keys = Set(Char).new
    @distance_stepped = 0
  end

  protected def initialize(@graph, @current_node, @held_keys, @distance_stepped)
  end

  def solve : Int32
    while @held_keys.proper_subset?(@graph.all_keys)
      if @@global_min <= @distance_stepped
        return @@global_min
      end

      if (min_steps_to_reach = @@distance_cache.dig?(@held_keys, @current_node)) && min_steps_to_reach <= @distance_stepped
        return @@global_min
      else
        step_cache = @@distance_cache[@held_keys] ||= Hash(Node, Int32).new
        step_cache[@current_node] = @distance_stepped
      end

      reachable = @graph.keys_reachable_from(@current_node, with_keys: @held_keys, max_distance: @@global_min - @distance_stepped)

      if reachable.size == 0
        return @@global_min
      end

      if reachable.size == 1
        reachable_key, key_distance = reachable.first

        @current_node = reachable_key
        @distance_stepped += key_distance
        @held_keys << reachable_key.key
        next
      end

      # We need to decide between multiple keys, and a simple greedy algorithm won't work.
      # Instead, try each choice and pick the best result.
      num_choices = reachable.size

      distances = reachable.map_with_index do |(key_node, value), i|
        chosen_keys = @held_keys.clone << key_node.key
        chosen_distance = @distance_stepped + value
        possible_state = GraphState.new(@graph, key_node, chosen_keys, chosen_distance)
        possible_state.solve
      end

      @distance_stepped = distances.min
      break
    end

    if @distance_stepped < @@global_min
      @@global_min = @distance_stepped
      print @@global_min, "< "
    end
    @distance_stepped
  end
end

def answer(input) : Int32
  grid = Grid.new(input)
  graph = Graph.new(grid)
  graph.simplify!

  when_verbose do
    pp graph
    puts graph.size
  end

  solver = GraphState.new(graph)
  solver.solve.tap { puts }
end
