nums = [] of Int32
File.each_line("input.txt") do |line|
  nums << line.to_i
end

# Part 1
nums.combinations(size: 2).each do |combo|
  if combo.sum == 2020
    puts combo.product
    break
  end
end

# Part 2
nums.combinations(size: 3).each do |combo|
  if combo.sum == 2020
    puts combo.product
    break
  end
end
