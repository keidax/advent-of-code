trees = [] of Array(Bool)
File.each_line("input.txt") do |line|
  tree_line = line.chars.map { |c| c == '#' }
  trees << tree_line
end

def trees_on_slope(trees, right, down) : Int64
  width = trees[0].size

  trees_hit = 0_i64
  row = 0
  col = 0

  until row == trees.size - 1
    row += down
    col = (col + right) % width

    if trees[row][col]
      trees_hit += 1
    end
  end

  trees_hit
end

# Part 1
puts trees_on_slope(trees, 3, 1)

# Part 2
slopes = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

puts slopes.map { |right, down|
  trees_on_slope(trees, right, down)
}.product
