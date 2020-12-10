adapters = File
  .read_lines("input.txt")
  .map(&.to_i)
  .sort

# Include the charging outlet and device adapter
adapters.unshift(0)
adapters << (adapters.last + 3)

# Part 1
differences = {1 => 0, 3 => 0}

adapters.each_cons_pair do |a, b|
  diff = b - a
  differences[diff] += 1
end

puts differences[1] * differences[3]

# Part 2
runs = adapters.chunk_while { |a, b| a + 1 == b }
puts runs.product { |run|
  # Input has no runs longer than 5 adapters
  case run.size
  when 1, 2 then 1_i64
  when 3    then 2_i64
  when 4    then 4_i64
  when 5    then 7_i64
  else           0_i64
  end
}
