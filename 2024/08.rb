require_relative "aoc"

input = AOC.day(8)

antenna_map = Hash.new { |h, k| h[k] = [] }
input.lines(chomp: true).each_with_index do |line, row|
  line.chars.each_with_index do |char, col|
    next if char == "."
    antenna_map[char] << [row, col]
  end
end

max_row, max_col = input.grid_bounds

ROW_RANGE = (0...max_row)
COL_RANGE = (0...max_col)

def each_antinode(a, b)
  row_a, col_a = a
  row_b, col_b = b

  row_diff = (row_a - row_b)
  col_diff = (col_a - col_b)

  antinode_a = [row_a + row_diff, col_a + col_diff]
  yield antinode_a if antinode_a in ROW_RANGE, COL_RANGE

  antinode_b = [row_b - row_diff, col_b - col_diff]
  yield antinode_b if antinode_b in ROW_RANGE, COL_RANGE
end

def each_resonant_antinode(a, b)
  row_a, col_a = a
  row_b, col_b = b

  row_diff = (row_a - row_b)
  col_diff = (col_a - col_b)

  yield a
  yield b

  loop do
    row_a += row_diff
    col_a += col_diff

    antinode = [row_a, col_a]
    break unless antinode in ROW_RANGE, COL_RANGE

    yield antinode
  end

  loop do
    row_b -= row_diff
    col_b -= col_diff

    antinode = [row_b, col_b]
    break unless antinode in ROW_RANGE, COL_RANGE

    yield antinode
  end
end

antinodes_part1 = Set.new
antinodes_part2 = Set.new

antenna_map.each do |char, antenna_list|
  antenna_list.combination(2).each do |a, b|
    each_antinode(a, b) { antinodes_part1 << _1 }
    each_resonant_antinode(a, b) { antinodes_part2 << _1 }
  end
end

AOC.part1 { antinodes_part1.count }
AOC.part2 { antinodes_part2.count }
