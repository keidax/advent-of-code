require "./aoc"

AOC.day!(5)

def build_map(section)
  ranges = section[1..].map do |line|
    dest, source, length = line.split(" ").map(&.to_i64)
    offset = dest - source
    range = source...(source + length)

    {range, offset}
  end

  ranges.sort_by!(&.[0].begin)
end

def convert_seed_to_location(seed, maps)
  maps.reduce(seed) do |value, map|
    convert_single_map(value, map)
  end
end

def convert_single_map(value, map)
  map.each do |range, offset|
    if range.includes?(value)
      return value + offset
    end
  end

  value
end

sections = AOC.line_sections

seeds = sections[0][0].split(" ")[1..].map(&.to_i64)
maps = sections[1..].map { |s| build_map(s) }

AOC.part1 do
  seeds.map { |s| convert_seed_to_location(s, maps) }.min
end

# Find all the numbers where a range either begins or ends.
# For ranges like (0...5, 5...8, 10...12), the result will be
# [0, 5, 8, 10, 12]
# Note: this assumes ranges are exclusive, in sorted order, and don't overlap.
def boundaries(ranges)
  boundaries = [] of Int64
  next_bound = -1

  ranges.each do |range|
    if range.begin != next_bound
      next_bound = range.begin
      boundaries << next_bound
    end

    if range.end != next_bound
      next_bound = range.end
      boundaries << next_bound
    end
  end

  boundaries
end

# Given a list of ranges and boundaries, split any ranges containing a boundary into multiple ranges
# so that no boundary falls in the middle of a range.
# For input like ([0...5, 5...10], [3, 7, 12]) the result will be
# [0...3, 3...5, 5...7, 7...10]
# Note: this assumes boundaries are sorted
def split_along_boundaries(ranges, boundaries)
  out_ranges = [] of Range(Int64, Int64)

  ranges.each do |range|
    boundaries.each do |bound|
      if range.includes?(bound) && range.begin != bound
        pre_bound = range.begin...bound
        range = bound...range.end
        out_ranges << pre_bound
      end
    end
    out_ranges << range
  end

  out_ranges
end

# Given a series of ranges and a conversion map, return the converted ranges
def convert_ranges_in_map(ranges, map)
  bounds = boundaries(map.map(&.[0]))
  ranges = split_along_boundaries(ranges, bounds)

  ranges.map do |range|
    converted = range
    map.each do |(conv_range, offset)|
      if conv_range.includes?(range.begin) # this works because we've already split along range boundaries
        converted = (range.begin + offset)...(range.end + offset)
        break
      end
    end
    converted
  end
end

AOC.part2 do
  ranges = seeds.each_slice(2).map { |(start, len)| start...(start + len) }.to_a

  maps.each do |map|
    ranges = convert_ranges_in_map(ranges, map)
  end

  ranges.sort_by(&.begin).first.begin
end
