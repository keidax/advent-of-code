require "../aoc"

AOC.day!(1)

nums = [] of Int32?

AOC.each_line do |line|
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

AOC.part1 { total_calories[-1] }
AOC.part2 { total_calories[-3..-1].sum }
