require_relative "aoc"

input = AOC.day(19)

towels, designs = input.line_sections
towels = towels[0].split(", ").sort

towel_branch = towels.join("|")
regex = /^(?:#{towel_branch})+$/

possible, _impossible = designs.partition { regex.match? _1 }

AOC.part1 do
  possible.size
end

def combo_count(string, towel_map, memo)
  return 1 if string.size == 0

  if (count = memo.fetch(string, nil))
    return count
  end

  total = 0

  towel_map[string[0]].each do |towel|
    if string.start_with?(towel)
      total += combo_count(string[towel.size..], towel_map, memo)
    end
  end

  memo[string] = total
  total
end

AOC.part2 do
  memo = {}

  # optimization: group towels by the first character, so we only need to call
  # .start_with? for a subset
  towel_map = towels.group_by { _1[0] }

  possible.map { combo_count(_1, towel_map, memo) }.sum
end
