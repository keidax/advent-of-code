require_relative "aoc"

input = AOC.day(1)

left, right = input.lines.map do |line|
  line.split.map(&:to_i)
end.transpose

left.sort!
right.sort!

AOC.part1 do
  left.zip(right).reduce(0) do |m, (l, r)|
    m + (l - r).abs
  end
end

left_tally = left.tally
right_tally = right.tally

AOC.part2 do
  left_tally.reduce(0) do |m, (number, l_count)|
    r_count = right_tally.fetch(number, 0)
    m + number * l_count * r_count
  end
end
