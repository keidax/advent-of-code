alias MapHash = Hash(String, Array(String))

orbits = MapHash.new(->(hash : MapHash, key : String) { hash[key] = [] of String })

File.each_line("input.txt") do |line|
  center, orbit = line.split ')'
  orbits[center] << orbit
end

def orbiting_objs(orbits, start : String, current : Int32) : Int32
  return current +
    orbits[start]
      .map { |obj| orbiting_objs(orbits, obj, current + 1) }
      .sum
end

puts orbiting_objs(orbits, "COM", 0)
