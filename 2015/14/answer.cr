class Reindeer
  getter name : String
  getter speed : Int32, time : Int32, rest_time : Int32

  def initialize(@name, @speed, @time, @rest_time)
  end

  def distance_at(seconds) : Int32
    cycle = @time + @rest_time

    whole_cycles = (seconds // cycle) * (speed * time)

    partial_time = seconds % cycle

    if partial_time > @time
      return whole_cycles + (speed * time)
    else
      return whole_cycles + (speed * partial_time)
    end
  end
end

REINDEERS = [] of Reindeer

File.each_line("input.txt") do |line|
  line.match /(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds./

  REINDEERS << Reindeer.new($1, $2.to_i, $3.to_i, $4.to_i)
end

# Part 1
puts REINDEERS.map { |reindeer| reindeer.distance_at(2503) }.max

# Part 2
POINTS = REINDEERS.to_h { |reindeer| {reindeer, 0} }

(1..2503).each do |time|
  scores = {} of Int32 => Array(Reindeer)
  REINDEERS.each do |reindeer|
    distance = reindeer.distance_at(time)

    scores[distance] ||= [] of Reindeer
    scores[distance] << reindeer
  end

  top_score = scores.keys.max

  scores[top_score].each do |leader|
    POINTS[leader] += 1
  end
end

puts POINTS.values.max
