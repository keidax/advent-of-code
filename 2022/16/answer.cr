require "bit_array"

require "../aoc"

AOC.day!(16)

class Valve
  property flow_rate : Int32
  property tunnel_names : Array(String)

  def initialize(@flow_rate, @tunnel_names)
  end
end

all_valves = AOC.lines.to_h do |line|
  unless line =~ /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/
    raise "could not parse line '#{line}'"
  end

  name = $1
  rate = $2.to_i
  tunnels = $3.split(", ")

  {name, Valve.new(rate, tunnels)}
end

non_zero_valve_keys = all_valves.keys.select { |name| all_valves[name].flow_rate > 0 }
valve_keys = (non_zero_valve_keys + ["AA"]).sort
valves_by_id = valve_keys.map { |name| all_valves[name] }

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
      # Add 1 here to account for the time to open the valve
      result[current_node.name] = current_node.distance + 1
      goals.delete(current_node.name)
    end

    # this would be much more efficient if we used a heap
    unvisited.unstable_sort_by!(&.distance)
  end

  result
end

key_set = Set.new(non_zero_valve_keys)

initial_distances = distance_to_valves("AA", all_valves, key_set.clone).to_h do |valve_name, distance|
  {valve_keys.index!(valve_name).to_u8, distance}
end
map = non_zero_valve_keys.to_h do |valve_name|
  distances_from_valve = distance_to_valves(valve_name, all_valves, key_set - [valve_name]).to_h do |valve_name, distance|
    {valve_keys.index!(valve_name).to_u8, distance}
  end

  {valve_keys.index!(valve_name).to_u8, distances_from_valve}
end

ClosedValves.size = valve_keys.size

PressureResult.valves = valve_keys.map { |name| all_valves[name] }
PressureResult.map = map

# Represent the open/closed state of all valves in a memory-efficient way
struct ClosedValves
  class_property size = 0

  include Enumerable(UInt8)

  getter closed : BitArray

  def initialize
    @closed = BitArray.new(@@size, true)
    # AA, valve id 0, is always considered "open"
    @closed[0] = false
  end

  def initialize(@closed)
  end

  def inverse
    inverted = @closed.dup
    inverted.invert
    inverted[0] = false
    self.class.new(inverted)
  end

  def each
    @closed.each_with_index do |closed, valve_id|
      yield valve_id.to_u8 if closed
    end
  end

  def opened(valve_id)
    opened = @closed.dup
    raise "valve id #{valve_id} is already open" unless opened[valve_id]
    opened[valve_id] = false
    self.class.new(opened)
  end
end

# Represent the current state of someone (i.e. you or the elephant) opening valves.
struct PressureResult
  class_property valves = [] of Valve
  class_property map = {} of UInt8 => Hash(UInt8, Int32)
  class_property cache = Hash(PressureResult, Int32).new { |h, result| h[result] = result.best_pressure }

  def self.best_pressure(valve_id, time_left, closed)
    @@cache[self.new(valve_id, time_left, closed)]
  end

  # The valve you are currently located at
  @current_valve_id : UInt8
  # How much time is left, in minutes
  @time_left : Int8
  # The group of valves that haven't been opened yet
  @closed : ClosedValves

  def initialize(@current_valve_id, @time_left, @closed)
    raise "valve must be closed" if !@closed.closed[@current_valve_id]

    if @time_left < 0
      @time_left = 0
    end
  end

  # The most _additional_ pressure you can release by opening valves from this
  # state. Pressure from already-open valves is not included.
  def best_pressure : Int32
    return 0 if @time_left <= 0

    this_valve = @time_left.to_i * @@valves[@current_valve_id].flow_rate

    other_valves_max = 0

    next_closed = @closed.opened(@current_valve_id)

    next_closed.each do |next_valve_id|
      distance = @@map[@current_valve_id][next_valve_id]
      next_time = @time_left - distance
      next if next_time <= 0

      other_valves = self.class.best_pressure(next_valve_id, next_time, next_closed)
      if other_valves > other_valves_max
        other_valves_max = other_valves
      end
    end

    this_valve + other_valves_max
  end
end

AOC.part1 do
  closed = ClosedValves.new
  initial_distances.map do |first_valve_id, distance|
    PressureResult.best_pressure(first_valve_id.to_u8, 30.to_i8 - distance, closed)
  end.max
end

AOC.part2 do
  valve_count = valve_keys.size.to_u8
  (1..valve_keys.size//2).flat_map do |num_elephant_valves|
    (1_u8...valve_count).to_a.each_combination(num_elephant_valves).map do |elephant_combo|
      closed_bits = BitArray.new(valve_count, true)
      closed_bits[0] = false
      elephant_combo.each do |elephant_valve_id|
        closed_bits[elephant_valve_id] = false
      end

      closed = ClosedValves.new(closed_bits)
      elephant_closed = closed.inverse

      human_max = closed.max_of do |first_valve_id|
        distance = initial_distances[first_valve_id]

        PressureResult.best_pressure(first_valve_id, 26.to_i8 - distance, closed)
      end

      elephant_max = elephant_closed.max_of do |first_valve_id|
        distance = initial_distances[first_valve_id]

        PressureResult.best_pressure(first_valve_id, 26.to_i8 - distance, elephant_closed)
      end

      human_max + elephant_max
    end
  end.max
end
