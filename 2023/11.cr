require "./aoc"

AOC.day!(11)

def empty_rows(lines)
  empty_rows = [] of Int32

  lines.each_with_index do |line, i|
    if line =~ /^\.*$/
      empty_rows << i
    end
  end

  empty_rows
end

def empty_columns(lines)
  empty_columns = [] of Int32

  chars_array = lines.map(&.chars)
  (0...chars_array[0].size).each do |col|
    if chars_array.all? { |chars| chars[col] == '.' }
      empty_columns << col
    end
  end

  empty_columns
end

alias Galaxy = {x: Int32, y: Int32}

def load_galaxies(lines)
  galaxies = [] of Galaxy

  lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
      if c == '#'
        galaxies << {x: x, y: y}
      end
    end
  end

  galaxies
end

def sum_pair_distances(lines, expansion_factor)
  galaxies = load_galaxies(lines)
  empty_rows = empty_rows(lines)
  empty_cols = empty_columns(lines)

  galaxies.each_combination(2).sum do |(a, b)|
    x_range = Math.min(a[:x], b[:x])..Math.max(a[:x], b[:x])
    y_range = Math.min(a[:y], b[:y])..Math.max(a[:y], b[:y])

    x_dist = (a[:x] - b[:x]).abs + empty_cols.count { |x| x_range.covers?(x) } * (expansion_factor - 1)
    y_dist = (a[:y] - b[:y]).abs + empty_rows.count { |y| y_range.covers?(y) } * (expansion_factor - 1)

    x_dist.to_i64 + y_dist.to_i64
  end
end

AOC.part1 { sum_pair_distances(AOC.lines, 2) }
AOC.part2 { sum_pair_distances(AOC.lines, 1_000_000) }
