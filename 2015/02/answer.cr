alias Present = { Int64, Int64, Int64}

def parse_line(line : String) : Present
    Present.from(line.split('x').map(&.to_i64).sort)
end

def area(present) : Int
    3 * present[0] * present[1] + 2 * present[0] * present[2] + 2 * present[1] * present[2]
end

sq_feet = 0

File.each_line("input.txt") do |line|
    sq_feet += area(parse_line(line))
end

puts sq_feet
