packages = [] of Int32
File.each_line("input.txt") do |line|
  packages << line.to_i32
end

def find_fewest_packages(packages, target_weight) : Array(Array(Int32))?
  packages = packages.sort.reverse

  group = [] of Int32

  # Start by picking the largest values
  while group.sum < target_weight
    group << packages[group.size]
  end

  min_size = group.size

  loop do
    possiblities = find_fewest_with_prefix(packages, [] of Int32, target_weight, min_size)
    return possiblities if possiblities.try &.any?
    min_size += 1
  end
end

def find_fewest_with_prefix(packages, prefix, target_weight, target_size) : Array(Array(Int32))?
  # select packages not in the prefix
  if prefix.empty?
    start_idx = 0
  else
    start_idx = packages.index(prefix.last).not_nil! + 1
  end

  if target_size - prefix.size == 1
    # We can search for a single package to fit the weight
    search_idx = start_idx
    prefix_sum = prefix.sum

    founds = [] of Array(Int32)

    while search_idx < packages.size
      current_weight = prefix_sum + packages[search_idx]
      if current_weight == target_weight
        return [prefix + [packages[search_idx]]]
      elsif current_weight > target_weight
        search_idx += 1
      else
        return nil
      end
    end
  else
    # Iterate through the possible prefixes
    search_idx = start_idx
    founds = [] of Array(Int32)

    while search_idx < packages.size
      found = find_fewest_with_prefix(packages, prefix + [packages[search_idx]], target_weight, target_size)

      if found.try &.any?
        founds.concat found.not_nil!
      end
      search_idx += 1
    end

    founds
  end
end

# Part 1
fewest = find_fewest_packages(packages, packages.sum // 3).not_nil!
pp fewest.map { |pos| pos.map(&.to_i64).product }.min

# Part 2
fewest = find_fewest_packages(packages, packages.sum // 4).not_nil!
pp fewest.map { |pos| pos.map(&.to_i64).product }.min
