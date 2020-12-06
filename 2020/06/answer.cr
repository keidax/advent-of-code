lines = File.read_lines("input.txt")

groups = lines
  .chunks(&.blank?)
  .reject! { |blank, _| blank }
  .map { |_, lines| lines }

# Part 1
puts groups
  .map { |lines| lines.join("").chars.uniq.size }
  .sum

# Part 2
pp groups
  .map { |lines| {lines.size, lines.join("").chars.tally} }
  .map { |size, tally| tally.count { |_, num| num == size } }
  .sum
