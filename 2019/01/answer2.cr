def total_fuel(mass : Int32) : Int32
  total = prev = partial_fuel(mass)

  loop do
    prev = partial_fuel(prev)
    break if prev <= 0
    total += prev
  end

  return total
end

def partial_fuel(mass : Int32) : Int32
  (mass / 3).floor.to_i - 2
end

lines = [] of Int32
File.each_line("input.txt") do |line|
  lines << line.to_i
end

sum = lines.map { |i| total_fuel(i) }.sum

puts sum
