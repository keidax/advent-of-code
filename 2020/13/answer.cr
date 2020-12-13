lines = File.read_lines("input.txt")

# Part 1
earliest_time = lines[0].to_i
buses = lines[1].split(",").map(&.to_i?).compact

earliest_bus = buses
  .map { |bus| {bus, (bus - (earliest_time % bus))} }
  .min_by { |_, wait_time| wait_time }

puts earliest_bus[0] * earliest_bus[1]

# Part 2
conditions = {} of UInt64 => UInt64
lines[1].split(",").each_with_index do |bus, i|
  next unless (bus = bus.to_u64?)
  conditions[bus] = i.to_u64
end

time = 0_u64
step = 1_u64

conditions.each do |bus, offset|
  until (time + offset) % bus == 0
    time += step
  end
  step *= bus
end

puts time
