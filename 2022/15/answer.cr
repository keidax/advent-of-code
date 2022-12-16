require "../aoc"

AOC.day!(15)

# Find the Manhattan distance between two x,y points
def distance(point1, point2)
  x1, y1 = point1
  x2, y2 = point2

  (x1 - x2).abs + (y1 - y2).abs
end

# Format: { x, y, radius }
sensors = AOC.lines.map do |line|
  num = /(-?\d+)/
  if line =~ /Sensor at x=#{num}, y=#{num}: closest beacon is at x=#{num}, y=#{num}/
    sensor = {$1.to_i, $2.to_i}
    beacon = {$3.to_i, $4.to_i}

    {*sensor, distance(sensor, beacon)}
  else
    raise "could not parse line '#{line}'"
  end
end

# Return an array of all ranges covered by sensors on a given row
def positions_in_row(sensors, y_row)
  sensors
    .select { |x, y, r| ((y - r)..(y + r)).includes?(y_row) }
    .map { |sensor| range_in_row(sensor, y_row) }
end

# For a given sensor, return a range of all the points covered by the sensor on the given row
def range_in_row(sensor, y_row)
  x, y, r = sensor

  y_offset = (y_row - y).abs
  x_leeway = r - y_offset
  x_min, x_max = x - x_leeway, x + x_leeway

  x_min..x_max
end

# Take an array of ranges, and combine all ranges that overlap
def merge_ranges(ranges)
  ranges.reduce([] of Range(Int32, Int32)) do |acc, range|
    while mergable = acc.find { |other_range| overlap?(range, other_range) }
      acc.delete(mergable)
      range = merge(range, mergable)
    end

    acc << range
    acc
  end
end

# Returns true if r2 is completely within the bounds of r1
def completely_within?(r1, r2)
  r1.begin <= r2.begin && r1.end >= r2.end
end

# Returns true if the ranges overlap
def overlap?(range1, range2)
  range1.includes?(range2.begin) || range1.includes?(range2.end) ||
    completely_within?(range2, range1)
end

# Returns a new range representing the union of a and b
def merge(a : Range, b : Range)
  begin_val = if a.begin < b.begin
                a.begin
              else
                b.begin
              end

  end_val = if a.end > b.end
              a.end
            else
              b.end
            end

  begin_val..end_val
end

# Given an array of ranges representing points, returns an array of the overlaps between adjoining ranges.
# This assumes the area covered by all the ranges is continous (no gaps)
def find_overlaps(ranges)
  ranges
    .sort_by { |r| r.begin }
    .reduce([] of Range(Int32, Int32)) do |acc, range|
      if acc.any? { |other_range| completely_within?(other_range, range) }
        # skip
      else
        acc << range
      end
      acc
    end
    .each_cons(2)
    .map { |ranges| (ranges[1].begin..ranges[0].end) }
    .to_a
end

# Given an array of ranges representing overlapping points, determine how far vertically the
# completely covered region covers.
def min_y_advance(ranges)
  find_overlaps(ranges)
    .map { |r| (r.end - r.begin) // 2 }
    .min + 1
end

# Given an array of ranges with exactly 1 point not covered by the ranges, return that point
def find_gap(merged_ranges)
  merged_ranges
    .sort_by { |r| r.begin }
    .each_cons_pair do |r1, r2|
      if r1.end + 2 == r2.begin
        return r1.end + 1
      end
    end

  raise "could not find single gap in #{merged_ranges}"
end

AOC.part1 do
  ranges = positions_in_row(sensors, 2_000_000)
  merge_ranges(ranges).map { |r| r.end - r.begin }.sum
end

AOC.part2 do
  y = 0

  loop do
    ranges = positions_in_row(sensors, y)
    merged = merge_ranges(ranges)
    if merged.size == 1
      y += min_y_advance(ranges)
    else
      x = find_gap(merged)

      break (4_000_000i64 * x) + y
    end

    break if y > 4_000_000
  end
end
