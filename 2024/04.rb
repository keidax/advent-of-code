require_relative "aoc"

input = AOC.day(4)

grid = input.lines(chomp: true).map { _1.chars.map(&:to_sym) }

# standard:disable Layout
XMAS_COORDS = [
  [[-1,  0], [-2,  0], [-3,  0]], # up
  [[-1, -1], [-2, -2], [-3, -3]], # up-left
  [[ 0, -1], [ 0, -2], [ 0, -3]], # left
  [[ 1, -1], [ 2, -2], [ 3, -3]], # down-left
  [[ 1,  0], [ 2,  0], [ 3,  0]], # down
  [[ 1,  1], [ 2,  2], [ 3,  3]], # down-right
  [[ 0,  1], [ 0,  2], [ 0,  3]], # right
  [[-1,  1], [-2,  2], [-3,  3]]  # up-right
]
# standard:enable Layout

XMAS_ROW_RANGE = (0..(grid.size - 1))
XMAS_COL_RANGE = (0..(grid[0].size - 1))

def check_xmas(grid, row, col)
  return 0 if grid[row][col] != :X

  XMAS_COORDS.sum do |sequence|
    m, a, s = sequence

    if !XMAS_ROW_RANGE.cover?(row + s[0])
      # row out of bounds
      next 0
    end
    if !XMAS_COL_RANGE.cover?(col + s[1])
      # col out of bounds
      next 0
    end

    if grid[row + m[0]][col + m[1]] == :M
      if grid[row + a[0]][col + a[1]] == :A
        if grid[row + s[0]][col + s[1]] == :S
          # XMAS matched
          next 1
        end
      end
    end

    # no match
    0
  end
end

def check_x_mas(grid, row, col)
  return 0 if grid[row][col] != :A

  up_left = grid[row - 1][col - 1]
  down_left = grid[row + 1][col - 1]
  down_right = grid[row + 1][col + 1]
  up_right = grid[row - 1][col + 1]

  if (up_left == :M && down_right == :S) || (up_left == :S && down_right == :M)
    if (up_right == :M && down_left == :S) || (up_right == :S && down_right == :M)
      # MAS matched on both diagonals
      return 1
    end
  end

  # no match
  0
end

AOC.part1 do
  xmas_count = 0

  XMAS_ROW_RANGE.each do |row|
    XMAS_COL_RANGE.each do |col|
      xmas_count += check_xmas(grid, row, col)
    end
  end

  xmas_count
end

AOC.part2 do
  x_mas_count = 0

  (1..(grid.size - 2)).each do |row|
    (1..(grid[0].size - 2)).each do |col|
      x_mas_count += check_x_mas(grid, row, col)
    end
  end

  x_mas_count
end
