require "../aoc"

AOC.day!(6)

data = AOC.input.strip.chars

def end_of_uniq_marker(data, size)
  i = 0

  data.each_cons(count: size, reuse: true) do |chars|
    if chars == chars.uniq
      i += size
      break
    else
      i += 1
    end
  end

  i
end

AOC.part1 { end_of_uniq_marker(data, 4) }
AOC.part2 { end_of_uniq_marker(data, 14) }
