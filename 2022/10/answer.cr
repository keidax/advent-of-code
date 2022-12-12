require "../aoc"

AOC.day!(10)

instructions = [] of Int32?

AOC.each_line do |line|
  case line
  when /noop/
    instructions << nil
  when /addx (-?\d+)/
    instructions << $1.to_i
  else
    raise "could not parse line '#{line}'"
  end
end

# Returns the value of the X register at the start of each cycle
def calculate_values(instructions)
  x = 1

  values = [] of Int32

  instructions.each do |i|
    if i
      # addx:
      # takes two cycles, x changes after the second cycle
      values << x
      values << x
      x += i
    else
      # noop:
      # takes one cycle, no change to x
      values << x
    end
  end

  values
end

def print_line(values)
  values.each_with_index do |x, i|
    if ((x - 1)..(x + 1)).includes?(i)
      print '█'
    else
      print '.'
    end
  end
  puts
end

values = calculate_values(instructions)

AOC.part1 do
  signal_cycles = [20, 60, 100, 140, 180, 220]
  signal_cycles.map { |c| values[c - 1] * c }.sum
end

AOC.part2 do
end

values.each_slice(40) do |raster_line|
  print_line(raster_line)
end
