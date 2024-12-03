require_relative "aoc"

MUL_PATTERN = /mul\((\d{1,3}),(\d{1,3})\)/
MUL_DO_DONT_PATTERN = /mul\((\d{1,3}),(\d{1,3})\)|(do)\(\)|(don't)\(\)/

input = AOC.day(3)

AOC.part1 do
  input.scan(MUL_PATTERN).sum do |x, y|
    x.to_i * y.to_i
  end
end

AOC.part2 do
  input.scan(MUL_DO_DONT_PATTERN).sum do |x, y, on, off|
    # Is this... an actual use for the flip-flop operator?!
    next 0 if off..on # standard:disable Lint/FlipFlop

    x.to_i * y.to_i
  end
end
