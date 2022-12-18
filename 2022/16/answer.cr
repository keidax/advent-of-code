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

def max_release(time_left, current_release, current_node, map, remaining_nodes : Set(String)) : Int32
  return current_release if remaining_nodes.empty?

  remaining_nodes.map do |next_node|
    distance = map[current_node][next_node]

    new_time_left = time_left - distance - 1
    if new_time_left <= 0
      next current_release
    end

    new_release = current_release + new_time_left * VALVES[next_node].flow_rate

    max_release(new_time_left, new_release, next_node, map, remaining_nodes - [next_node])
  end.max
end

AOC.part1 do
  initial_distances.map do |first_node, distance|
    time_left = 30 - distance - 1

    release = time_left * VALVES[first_node].flow_rate

    max_release(time_left, release, first_node, map, key_set - [first_node])
  end.max
end
