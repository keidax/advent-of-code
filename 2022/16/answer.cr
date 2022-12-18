require "../aoc"

AOC.day!(16)

class Valve
  property flow_rate : Int32
  property tunnel_names : Array(String)

  def initialize(@flow_rate, @tunnel_names)
  end
end

VALVES = {} of String => Valve

AOC.lines.each do |line|
  unless line =~ /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/
    raise "could not parse line '#{line}'"
  end

  name = $1
  rate = $2.to_i
  tunnels = $3.split(", ")

  VALVES[name] = Valve.new(rate, tunnels)
end

important_valve_names = VALVES.keys.select { |name| VALVES[name].flow_rate > 0 }
valve_keys = important_valve_names.sort

class Node
  property name : String
  property distance : Int32 = Int32::MAX

  def initialize(@name)
  end
end

def distance_to_valves(start : String, valves : Hash(String, Valve), goals : Set(String)) : Hash(String, Int32)
  nodes = valves.map { |name, _valve| Node.new(name) }
  nodes.find! { |n| n.name == start }.distance = 0

  unvisited = nodes.sort_by(&.distance)
  result = {} of String => Int32

  while goals.any?
    current_node = unvisited.shift

    valves[current_node.name].tunnel_names.each do |name|
      next_node = nodes.find! { |n| n.name == name }

      next_node.distance = Math.min(next_node.distance, current_node.distance + 1)
    end

    if goals.includes?(current_node.name)
      result[current_node.name] = current_node.distance
      goals.delete(current_node.name)
    end

    # this would be much more efficient if we used a heap
    unvisited.unstable_sort_by!(&.distance)
  end

  result
end

key_set = Set.new(valve_keys)

initial_distances = distance_to_valves("AA", VALVES, key_set.clone)
map = valve_keys.to_h do |valve_name|
  distances_from_valve = distance_to_valves(valve_name, VALVES, key_set - [valve_name])

  {valve_name, distances_from_valve}
end

struct Actor
  property moving_to : String
  property distance : Int32

  def initialize(@moving_to, @distance)
  end
end

STATE_CACHE = {} of {Int32, Set(String)} => Int32

def max_release_at_minute(minutes_left, actors : Array(Actor), current_release, map, remaining_nodes : Set(String)) : Int32
  if minutes_left == 0
    return current_release
  end

  actors = actors.map! { |actor| actor.distance -= 1; actor }
  minutes_left -= 1

  ready_actors, moving_actors = actors.partition { |actor| actor.distance == -1 }

  ready_actors.each do |actor|
    current_release += minutes_left * VALVES[actor.moving_to].flow_rate
  end

  if ready_actors.empty?
    return max_release_at_minute(minutes_left, moving_actors, current_release, map, remaining_nodes)
  end

  if remaining_nodes.empty?
    if moving_actors.empty?
      # all nodes are visited
      return current_release
    else
      return max_release_at_minute(minutes_left, moving_actors, current_release, map, remaining_nodes)
    end
  end

  if remaining_nodes.size < ready_actors.size
    # there are fewer nodes than actors left, so we have to try different combinations of actors
    remaining_nodes.to_a.permutations(remaining_nodes.size).map do |next_nodes|
      ready_actors.permutations(remaining_nodes.size).map do |actor_group|
        new_actors = actor_group.zip(next_nodes).map do |actor, next_node|
          distance_to_next_node = map[actor.moving_to][next_node]
          actor.moving_to = next_node
          actor.distance = distance_to_next_node
          actor
        end

        new_remaining_nodes = remaining_nodes - next_nodes
        next_actors = moving_actors + new_actors

        max_release_at_minute(minutes_left, next_actors, current_release, map, new_remaining_nodes)
      end.max
    end.max
  else
    remaining_nodes.to_a.permutations(ready_actors.size).map do |next_nodes|
      new_actors = ready_actors.zip(next_nodes).map do |actor, next_node|
        distance_to_next_node = map[actor.moving_to][next_node]
        actor.moving_to = next_node
        actor.distance = distance_to_next_node
        actor
      end

      new_remaining_nodes = remaining_nodes - next_nodes
      next_actors = moving_actors + new_actors

      max_release_at_minute(minutes_left, next_actors, current_release, map, new_remaining_nodes)
    end.max
  end
end

AOC.part1 do
  initial_distances.map do |first_node, distance|
    actors = [Actor.new(first_node, distance)]
    max_release_at_minute(30, actors, 0, map, key_set - [first_node])
  end.max
end

# TODO: This is quite slow, figure out some optimizations
AOC.part2 do
  initial_distances.to_a.combinations(2).map do |initial_nodes|
    actors = initial_nodes.map { |first_node, distance| Actor.new(first_node, distance) }
    max_release_at_minute(26, actors, 0, map, key_set - actors.map(&.moving_to))
  end.max
end
