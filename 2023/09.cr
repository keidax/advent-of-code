require "./aoc"

AOC.day!(9)

def extrapolate_extremes(values) : {Int32, Int32}
  differences = [] of Int32

  values.each_cons_pair do |a, b|
    differences << (b - a)
  end

  if differences.all?(&.zero?)
    {values.first, values.last}
  else
    prev_diff, next_diff = extrapolate_extremes(differences)

    {
      values.first - prev_diff,
      values.last + next_diff,
    }
  end
end

histories = AOC.lines.map do |line|
  line.split(" ").map(&.to_i)
end

extrapolated = histories.map { |h| extrapolate_extremes(h) }

AOC.part1 { extrapolated.sum(&.[1]) }
AOC.part2 { extrapolated.sum(&.[0]) }
