require_relative "aoc"

input = AOC.day(5)
rules, updates = input.line_sections

order = Hash.new { |h, k| h[k] = {} }

rules.each do |rule|
  a, b = rule.split("|").map(&:to_i)

  order[a][b] = true
  order[b][a] = false
end

page_sort = ->(a, b) do
  if a == b
    0
  elsif order[a][b]
    -1
  elsif order[b][a]
    1
  end
end

updates.map! do |update|
  update.split(",").map(&:to_i)
end

sorted, unsorted = updates.partition do |update|
  update == update.sort(&page_sort)
end

AOC.part1 do
  sorted.sum do |update|
    update[update.size / 2]
  end
end

AOC.part2 do
  unsorted.sum do |update|
    update.sort(&page_sort)[update.size / 2]
  end
end
