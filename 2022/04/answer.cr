require "../aoc"

AOC.day!(4)

pairs = [] of {Range(Int32, Int32), Range(Int32, Int32)}

def make_range(str)
  b, e = str.split("-")
  (b.to_i)..(e.to_i)
end

AOC.each_line do |line|
  a, b = line.split(",")
  pairs << {make_range(a), make_range(b)}
end

def contains_all?(a, b)
  a.includes?(b.begin) && a.includes?(b.end)
end

def contains_any?(a, b)
  a.includes?(b.begin) || a.includes?(b.end) || contains_all?(b, a)
end

AOC.part1 do
  pairs
    .select { |a, b| contains_all?(a, b) || contains_all?(b, a) }
    .size
end

AOC.part2 do
  pairs
    .select { |a, b| contains_any?(a, b) || contains_any?(b, a) }
    .size
end
