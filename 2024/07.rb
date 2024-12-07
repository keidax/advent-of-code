require_relative "aoc"

input = AOC.day(7)

equations = input.lines(chomp: true).map do |line|
  value, numbers = line.split(": ")
  [value.to_i, numbers.split(" ").map(&:to_i).reverse]
end

# optimized to avoid allocations by mutating the numbers array instead of
# copying it
def can_calibrate?(value, numbers, ops)
  a = numbers.pop
  b = numbers.pop

  ops.each do |op|
    c = a.send(op, b)

    numbers.push c

    if c > value
      next
    end

    if numbers.size == 1
      if value == numbers.first
        return true
      end
    elsif can_calibrate?(value, numbers, ops)
      return true
    end
  ensure
    numbers.pop # c
  end

  false
ensure
  numbers.push b
  numbers.push a
end

class Integer
  def concat(other)
    places = Math.log10(other).to_i + 1
    self * (10**places) + other
  end
end

AOC.part1 do
  equations
    .select { can_calibrate?(_1[0], _1[1], [:+, :*]) }
    .sum { _1[0] }
end

AOC.part2 do
  equations
    .select { can_calibrate?(_1[0], _1[1], [:+, :*, :concat]) }
    .sum { _1[0] }
end
