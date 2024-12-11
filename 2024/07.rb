require_relative "aoc"

input = AOC.day(7)

equations = input.lines(chomp: true).map do |line|
  value, numbers = line.split(": ")
  [value.to_i, numbers.split(" ").map(&:to_i)]
end

def solvable?(value, numbers, concat: false)
  last_num = numbers.last

  if numbers.size == 1
    return last_num == value
  end

  if value % last_num == 0
    return true if solvable?(value / last_num, numbers[..-2], concat:)
  end

  if value > last_num
    return true if solvable?(value - last_num, numbers[..-2], concat:)
  end

  if concat && value.to_s.end_with?(last_num.to_s)
    places = Math.log10(last_num).to_i + 1
    return true if solvable?(value / (10**places), numbers[..-2], concat:)
  end

  false
end

AOC.part1 do
  equations
    .select { solvable?(*_1, concat: false) }
    .sum { _1[0] }
end

AOC.part2 do
  equations
    .select { solvable?(*_1, concat: true) }
    .sum { _1[0] }
end
