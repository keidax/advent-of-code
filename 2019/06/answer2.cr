alias MapHash = Hash(String, Array(String))

orbits = MapHash.new(->(hash : MapHash, key : String) { hash[key] = [] of String })

File.each_line("input.txt") do |line|
  center, orbit = line.split ')'
  orbits[center] << orbit
end

def find_path(orbits, start : String, finish : String) : Array(String)?
  if orbits[start].empty?
    return nil
  end

  if orbits[start].includes?(finish)
    return [start]
  end

  sub_path = orbits[start].compact_map { |orbit| find_path(orbits, orbit, finish) }

  return nil if sub_path.empty?

  sub_path.first.unshift(start)
end

you_path = find_path(orbits, "COM", "YOU").not_nil!
san_path = find_path(orbits, "COM", "SAN").not_nil!

while you_path.first == san_path.first
  you_path.shift
  san_path.shift
end

puts you_path.size + san_path.size
