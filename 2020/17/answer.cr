alias Cube = Array(Int32)

# N-dimensional Tree
# A data structure representing a sparse n-dimensional space
class NTree
  property depth : Int32
  property nodes : Hash(Int32, NTree)
  property elems : Set(Int32)

  def_clone

  def initialize(dimensions)
    @depth = dimensions

    @nodes = {} of Int32 => NTree
    @elems = Set(Int32).new
  end

  def [](vec, index = 0) : Bool
    if vec.size != depth + index
      raise KeyError.new("wrong size #{vec.size} for NTree of depth #{depth}")
    end

    val = vec[index]

    if vec.size - 1 == index
      elems.includes?(val)
    else
      nodes.has_key?(val) && nodes[val][vec, index + 1]
    end
  end

  def []=(vec, active : Bool, index = 0)
    if vec.size != depth + index
      raise KeyError.new("wrong size #{vec.size} for NTree of depth #{depth}")
    end

    val = vec[index]

    if vec.size - 1 == index
      if active
        elems.add(val)
      else
        elems.delete(val)
      end
    else
      if nodes.has_key?(val)
        nodes[val][vec, index: index + 1] = active
      else
        nodes[val] = NTree.new(depth - 1)
        nodes[val][vec, index: index + 1] = active
      end
    end
  end

  def size
    if depth == 1
      return elems.size
    end

    size = 0
    nodes.each_value do |tree|
      size += tree.size
    end

    size
  end

  def ranges : Array(Array(Int32))
    if depth == 1
      if elems.any?
        return [elems.minmax.to_a]
      else
        return [[0, 0]]
      end
    end

    min, max = 0, 0

    sub_ranges = Array.new(depth - 1) { [0, 0] }
    nodes.each do |val, tree|
      max = val if val > max
      min = val if val < min

      tree.ranges.each_with_index do |(sub_min, sub_max), i|
        if sub_min < sub_ranges[i][0]
          sub_ranges[i][0] = sub_min
        end

        if sub_max > sub_ranges[i][1]
          sub_ranges[i][1] = sub_max
        end
      end
    end

    [[min, max]] + sub_ranges
  end

  def all_locations(&blk : Cube ->)
    all_ranges = ranges.map { |(min, max)| min - 1..max + 1 }

    all_locations(all_ranges, [] of Int32, &blk)
  end

  private def all_locations(ranges, coords, &blk : Cube ->)
    if coords.size == ranges.size
      yield coords
    else
      range = ranges[coords.size]
      range.each do |val|
        coords.push val
        all_locations(ranges, coords, &blk)
        coords.pop
      end
    end
  end
end

class PermutationCache
  @@cache : Hash(Int32, Array(Array(Int32))) = {} of Int32 => Array(Array(Int32))

  def self.get(size)
    @@cache[size] ||= begin
      permutations = [] of Array(Int32)
      [-1, 0, 1].each_repeated_permutation(size: size) do |offsets|
        permutations << offsets
      end
      permutations
    end
  end
end

def adjacent_cube_count(universe, cube, cutoff = Int32::MAX) : Int32
  count = 0

  PermutationCache.get(cube.size).each do |offsets|
    next if offsets.all?(&.zero?)

    neighbor = offsets.zip(cube).map { |(offset, val)| offset + val }
    count += 1 if universe[neighbor]

    break if count > cutoff
  end

  count
end

n = NTree.new(3)

original_cubes = [] of Cube

y = 0
File.each_line("input.txt") do |line|
  line.chars.each_with_index do |c, x|
    if c == '#'
      original_cubes << [x, y]
    end
  end

  y += 1
end

def simulate_with_dimensions(original_cubes, dimensions)
  universe = NTree.new(dimensions)

  original_cubes.each do |cube|
    mapped_cube = cube + [0] * (dimensions - cube.size)
    universe[mapped_cube] = true
  end

  6.times do
    print '#'
    new_universe = universe.clone

    universe.all_locations do |coords|
      active_neighbors = adjacent_cube_count(universe, coords, cutoff: 3)

      if universe[coords]
        unless active_neighbors == 2 || active_neighbors == 3
          new_universe[coords] = false
        end
      else
        if active_neighbors == 3
          new_universe[coords] = true
        end
      end
    end

    universe = new_universe
  end

  universe.size
end

# Part 1
puts simulate_with_dimensions(original_cubes, dimensions: 3)

# Part 2
puts simulate_with_dimensions(original_cubes, dimensions: 4)
