alias Present = {Int64, Int64, Int64}

def parse_line(line : String) : Present
  Present.from(line.split('x').map(&.to_i64).sort)
end

def area(present) : Int
  3 * present[0] * present[1] + 2 * present[0] * present[2] + 2 * present[1] * present[2]
end

def volume(present) : Int
  present[0] * present[1] * present[2]
end

def smallest_side(present) : Int
  2 * (present[0] + present[1])
end

ribbon_length = 0
sq_feet = 0

File.each_line("input.txt") do |line|
  present = parse_line(line)
  sq_feet += area(present)
  ribbon_length += volume(present) + smallest_side(present)
end

puts sq_feet
puts ribbon_length
