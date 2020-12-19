# The main data structure is a nested N-dimensional array.
# Most methods are optimized to avoid heap allocations.
alias NVec = Array(Bool) | Array(NVec)

def build_n_vec(dimensions) : NVec
  if dimensions.size == 1
    Array(Bool).new(size: dimensions[0]) { false }
  else
    lower_dimension = dimensions[1..]
    Array(NVec).new(size: dimensions[0]) { build_n_vec(lower_dimension) }
  end
end

# Get the value at the given coords, where each coordinate is a different dimension
# Safely handle out-of-bounds
def get(nvec, coords) : Bool?
  index = 0
  loop do
    if nvec.is_a?(Array(NVec))
      nvec = nvec[coords[index]]?
      index += 1
    else
      break
    end
  end

  nvec && nvec.as(Array(Bool))[coords[index]]?
end

# Assign the value at the given coords, where each coordinate is a different dimension
def assign(nvec, coords, value)
  coords.each_with_index do |d, i|
    if nvec.is_a?(Array(Bool))
      nvec[d] = value
    else
      nvec = nvec[d]
    end
  end
end

# Count how many locations are active across all dimensions
def sum(nvec) : Int32
  if nvec.is_a?(Array(Bool))
    nvec.count &.itself
  else
    nvec.sum { |v| sum(v) }
  end
end

# Call the given block for every location across all dimensions
def each_location(vec : NVec, coords = [] of Int32, &blk : Array(Int32), Bool ->)
  if vec.is_a?(Array(Bool))
    vec.each_with_index do |val, i|
      yield coords.push(i), val
      coords.pop
    end
  else
    vec.each_with_index do |sub_vec, i|
      each_location(sub_vec, coords.push(i), &blk)
      coords.pop
    end
  end
end

CUTOFF = 3

# Count how many locations adjacent to the given coords are active.
# "Adjacent" means each coordinate can differ by at most 1.
# Returns early if we've already reached the cutoff.
#
# is_zero tracks if the offset is 0 on all coords.
# In other words, it's the central location, not a neighbor.
def adjacent_locations(nvec, coords, depth = 0, is_zero = false) : Int32
  if depth + 1 == coords.size
    return adjacent_slice(nvec, coords, is_zero)
  end

  count = 0

  if coords[depth] > 0
    coords[depth] -= 1
    count += adjacent_locations(nvec, coords, depth: depth + 1)
    coords[depth] += 1
  end
  return count if count > CUTOFF

  if depth == 0
    count += adjacent_locations(nvec, coords, depth: depth + 1, is_zero: true)
  else
    count += adjacent_locations(nvec, coords, depth: depth + 1, is_zero: is_zero)
  end
  return count if count > CUTOFF

  coords[depth] += 1
  count += adjacent_locations(nvec, coords, depth: depth + 1)
  coords[depth] -= 1

  count
end

# Optimized base case for adjacent_locations
def adjacent_slice(nvec, coords, is_zero = false) : Int32
  index = 0

  while index < coords.size - 1
    if nvec.is_a?(Array(NVec))
      nvec = nvec[coords[index]]?
      index += 1
    else
      return 0
    end
  end

  if nvec.is_a?(Array(Bool))
    d = coords.last
    count = 0
    if d > 0 && nvec[d - 1]
      count += 1
    end

    if !is_zero && nvec[d]
      count += 1
    end

    if d < nvec.size - 1 && nvec[d + 1]
      count += 1
    end

    return count
  end

  return 0
end

# This is pretty inefficient because it simulates the entire region every round,
# instead of focusing on the bounded active region. But we can allocate the data
# structure all up front, instead of expanding it each round.
#
# This also ignores any mirroring in the simulation.
def simulate(dimensions, rounds)
  lines = File.read_lines("input.txt")

  # Build a matrix large enough to hold all values, assuming the active space
  # can increase by 1 in each direction each round.
  bounding = 2 * rounds
  dimension_bounds = [bounding + 1] * (dimensions - 2) + [bounding + lines.size, bounding + lines[0].size]
  universe = build_n_vec(dimension_bounds)

  prefix = [rounds] * (dimensions - 2)

  lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
      if c == '#'
        assign(universe, prefix + [y + rounds, x + rounds], true)
      end
    end
  end

  rounds.times do
    new_universe = universe.clone

    each_location(universe) do |coords|
      active_neighbors = adjacent_locations(universe, coords)

      if get(universe, coords)
        unless active_neighbors == 2 || active_neighbors == 3
          assign(new_universe, coords, false)
        end
      else
        if active_neighbors == 3
          assign(new_universe, coords, true)
        end
      end
    end

    universe = new_universe
  end

  universe
end

# Part 1
puts sum(simulate(3, 6))
# Part 2
puts sum(simulate(4, 6))
