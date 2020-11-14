DISTANCES = Hash(String, Hash(String, Int32)).new do |hash, key|
  hash[key] = Hash(String, Int32).new
end

File.each_line("input.txt") do |line|
  line.match(/(\w+) to (\w+) = (\d+)/)

  DISTANCES[$1][$2] = DISTANCES[$2][$1] = $3.to_i32
end

LOCATIONS = Set(String).new(DISTANCES.keys)

# Part 1
def travel_to_shortest(traveled) : Int32
  distances = [] of Int32
  last_stop = traveled.last

  (LOCATIONS - traveled).each do |location|
    traveled << location
    distances << (DISTANCES[last_stop][location] + travel_to_shortest(traveled))
    traveled.pop
  end

  return distances.min? || 0
end

puts(LOCATIONS.map do |location|
  travel_to_shortest([location])
end.min)

# Part 2
def travel_to_longest(traveled) : Int32
  distances = [] of Int32
  last_stop = traveled.last

  (LOCATIONS - traveled).each do |location|
    traveled << location
    distances << (DISTANCES[last_stop][location] + travel_to_longest(traveled))
    traveled.pop
  end

  return distances.max? || 0
end

puts(LOCATIONS.map do |location|
  travel_to_longest([location])
end.max)
