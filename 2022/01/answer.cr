nums = [] of Int32?
File.each_line("input.txt") do |line|
  if line.blank?
    nums << nil
  else
    nums << line.to_i
  end
end

total_calories = nums
  .chunks { |i|
    next Enumerable::Chunk::Drop unless i
    true
  }.map { |_, cals| cals.compact.sum }
  .sort

# Part 1
puts total_calories[-1]

# Part 2
puts total_calories[-3..-1].sum
