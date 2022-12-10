require "../aoc"

AOC.day!(8)

trees = [] of Array(Int32)

AOC.each_line do |line|
  tree_row = line.chars.map(&.to_i)
  trees << tree_row
end

def visible_in_sequence(locations : Enumerable({Int32, Int32}), trees)
  highest = -1

  visible = [] of {Int32, Int32}

  locations.each do |x, y|
    tree = trees[y][x]
    if tree > highest
      highest = tree
      visible << {x, y}
    end
  end

  visible
end

AOC.part1 do
  visible = [] of {Int32, Int32}

  (0...(trees.size)).each do |y|
    locations_from_left = (0...(trees[y].size)).map { |x| {x, y} }
    locations_from_right = locations_from_left.reverse

    visible
      .concat(visible_in_sequence(locations_from_left, trees))
      .concat(visible_in_sequence(locations_from_right, trees))
  end

  (0...(trees[0].size)).each do |x|
    locations_from_top = (0...(trees.size)).map { |y| {x, y} }
    locations_from_bottom = locations_from_top.reverse

    visible
      .concat(visible_in_sequence(locations_from_top, trees))
      .concat(visible_in_sequence(locations_from_bottom, trees))
  end

  visible.uniq.size
end

def view_distance(locations : Enumerable({Int32, Int32}), trees, max_height)
  count = 0

  locations.each do |x, y|
    tree = trees[y][x]
    count += 1

    if tree >= max_height
      break
    end
  end

  count
end

def scenic_score(x, y, trees)
  view_to_left = (0...x).map { |_x| {_x, y} }.reverse
  view_to_right = ((x + 1)...(trees[y].size)).map { |_x| {_x, y} }
  view_to_top = (0...y).map { |_y| {x, _y} }.reverse
  view_to_bottom = ((y + 1)...(trees.size)).map { |_y| {x, _y} }

  tree = trees[y][x]

  left = view_distance(view_to_left, trees, tree)
  right = view_distance(view_to_right, trees, tree)
  top = view_distance(view_to_top, trees, tree)
  bottom = view_distance(view_to_bottom, trees, tree)

  left * right * top * bottom
end

AOC.part2 do
  (1...(trees.size - 1)).flat_map do |y|
    (1...(trees[y].size - 1)).map do |x|
      scenic_score(x, y, trees)
    end
  end.max
end
