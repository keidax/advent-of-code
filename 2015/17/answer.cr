containers = [] of Int32

File.each_line("input.txt") do |line|
  containers << line.to_i32
end

# Find the smallest and largest number of containers that could conceivably
# fit 150 liters.
max_count = 0
sum = 0
containers.sort.each_with_index do |container, i|
  sum += container
  if sum >= 150
    max_count = i + 1
    break
  end
end

min_count = 0
sum = 0
containers.sort.reverse.each_with_index do |container, i|
  sum += container
  if sum >= 150
    min_count = i + 1
    break
  end
end

# Part 1
possibilities = 0
(min_count..max_count).each do |i|
  possibilities += containers.combinations(i).count do |container_group|
    container_group.sum == 150
  end
end
pp possibilities

# Part 2
num_containers = 0
(min_count..max_count).each do |i|
  containers.combinations(i).each do |container_group|
    if container_group.sum == 150
      num_containers = container_group.size
      break
    end
  end
  break if num_containers > 0
end

pp(containers.combinations(num_containers).count do |container_group|
  container_group.sum == 150
end)
