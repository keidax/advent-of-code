require "./aoc"

AOC.day!(6)

times = AOC.lines[0].split(/\s+/)[1..].map(&.to_i)
distances = AOC.lines[1].split(/\s+/)[1..].map(&.to_i)
races = times.zip(distances)

def possible_distances(race_time, prev_best)
  # Based on the formula
  #   time ** 2 - race_time * time + prev_best = 0
  # find the roots using the quadratic equation. This gives the lower and upper
  # bounds on how long we can hold the button and still win the race.

  low_time = ((race_time - Math.sqrt(race_time**2 - 4i64 * prev_best))/2).ceil.to_i64
  high_time = ((race_time + Math.sqrt(race_time**2 - 4i64 * prev_best))/2).floor.to_i64

  high_time - low_time + 1
end

AOC.part1 do
  races.map { |race| possible_distances(*race) }.product
end

AOC.part2 do
  race_time = times.map(&.to_s).join("").to_i64
  prev_best = distances.map(&.to_s).join("").to_i64

  possible_distances(race_time, prev_best)
end
