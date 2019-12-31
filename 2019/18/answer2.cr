require "../expect"

require "./multi_graph"
require "./multi_grid"
require "./node"

expect "Example 1", {<<-EX}, 8
#######
#a.#Cd#
##...##
##.@.##
##...##
#cB#Ab#
#######
EX

expect "Example 2", {<<-EX}, 24
###############
#d.ABC.#.....a#
######...######
######.@.######
######...######
#b.....#.....c#
###############
EX

expect "Example 3", {<<-EX}, 32
#############
#DcBa.#.GhKl#
#.###...#I###
#e#d#.@.#j#k#
###C#...###J#
#fEbA.#.FgHi#
#############
EX

expect "Example 4", {<<-EX}, 72
#############
#g#f.D#..h#l#
#F###e#E###.#
#dCba...BcIJ#
#####.@.#####
#nK.L...G...#
#M###N#H###.#
#o#m..#i#jk.#
#############
EX

puts answer File.read("input.txt")

class GlobalGraphState
  property(
    multi_graph : MultiGraph,
    states : Array(GraphState),
    held_keys : Set(Char),
    total_distance_stepped : Int32,
  )

  # Map keys + position to how many steps it took to reach that place
  class_getter distance_cache = Hash(Set(Char), Hash(Set(Node), Int32)).new
  class_getter global_min : Int32 = -1

  def initialize(graphs)
    @@distance_cache.clear
    @@global_min = 999_999_999

    @multi_graph = graphs
    @states = graphs.graphs.map { |graph| GraphState.new(graph) }.to_a
    @held_keys = Set(Char).new
    @total_distance_stepped = 0
  end

  protected def initialize(@multi_graph, @states, @held_keys, @total_distance_stepped)
  end

  def solve : Int32
    while @held_keys.proper_subset?(@multi_graph.all_keys)
      if @@global_min <= @total_distance_stepped
        return @@global_min
      end

      current_nodes = states.map(&.current_node).to_set

      if (min_steps_to_reach = @@distance_cache.dig?(@held_keys, current_nodes)) && min_steps_to_reach <= @total_distance_stepped
        return @@global_min
      else
        step_cache = @@distance_cache[@held_keys] ||= Hash(Set(Node), Int32).new
        step_cache[current_nodes] = @total_distance_stepped
      end

      remaining_key_count = @multi_graph.all_keys.size - @held_keys.size

      all_reachable = states.map_with_index do |state, i|
        reachable = state.graph.keys_reachable_from(state.current_node, with_keys: @held_keys, max_distance: @@global_min - @total_distance_stepped - remaining_key_count)
        if reachable.size == 0
          next
        end
        {state, reachable}
      end.compact

      if all_reachable.size == 1
        state, reachable_for_state = all_reachable.first
        if reachable_for_state.size == 1
          reachable_key, key_distance = reachable_for_state.first

          state.current_node = reachable_key
          @total_distance_stepped += key_distance
          @held_keys << reachable_key.key
          next
        end
      end

      if all_reachable.size == 0
        return @@global_min
      end

      # We have multiple choices. Try each choice and return the best result.
      distances = [] of Int32

      all_reachable.each do |state, reachable_for_state|
        reachable_for_state.each do |reachable_key, key_distance|
          chosen_keys = @held_keys.clone << reachable_key.key
          chosen_distance = @total_distance_stepped + key_distance

          new_state = state.dup
          new_state.current_node = reachable_key

          other_states = states.reject(state).map &.dup
          other_states << new_state

          possible_state = self.class.new(@multi_graph, other_states, chosen_keys, chosen_distance)
          distances << possible_state.solve
        end
      end

      @total_distance_stepped = distances.min
      break
    end

    if @total_distance_stepped < @@global_min
      @@global_min = @total_distance_stepped
      print @@global_min, "< "
    end
    @total_distance_stepped
  end
end

class GraphState
  property(
    graph : Graph,
    current_node : Node,
  )

  # Creates a new GraphState representing the start state.
  def initialize(@graph)
    @current_node = @graph.nodes.find(&.start?).not_nil!
  end
end

def answer(input) : Int32
  grid = MultiGrid.new(input)
  graphs = MultiGraph.new(grid)

  solver = GlobalGraphState.new(graphs)
  solver.solve.tap { puts }
end
