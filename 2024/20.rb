require_relative "aoc"

input = AOC.day(20)
max_row, max_col = input.grid_bounds
grid = Array.new(max_row) { Array.new(max_col, nil) }

start = finish = nil
input.lines(chomp: true).each_with_index do |line, row|
  line.chars.each_with_index do |char, col|
    case char
    when "#"
      next
    when "."
      grid[row][col] = Float::INFINITY
    when "S"
      grid[row][col] = 0
      start = [row, col]
    when "E"
      grid[row][col] = Float::INFINITY
      finish = [row, col]
    end
  end
end

# Find the next position while traveling through the maze
def next_pos(pos, grid)
  row, col = pos
  cur_score = grid[row][col]

  # start up
  if row > 0 &&
      (score = grid[row - 1][col]) &&
      score > cur_score
    [row - 1, col]
  elsif col > 0 &&
      (score = grid[row][col - 1]) &&
      score > cur_score
    [row, col - 1]
  elsif row + 1 < grid.size &&
      (score = grid[row + 1][col]) &&
      score > cur_score
    [row + 1, col]
  elsif col + 1 < grid[row].size &&
      (score = grid[row][col + 1]) &&
      score > cur_score
    [row, col + 1]
  end
end

# Scan a diamond-shaped pattern centered on pos with given radius.
# For each tile scanned, yield the score at the given tile and its distance to
# the center tile.
# This method is optimized for speed, and avoids heap allocations.
def scan_tiles_in_radius(pos, grid, radius)
  row, col = pos

  tile_row = row - radius
  tile_row_end = row + radius

  tile_col_start = col
  tile_col_end = col

  while tile_row <= tile_row_end
    if tile_row < 0
      if tile_row < row
        tile_col_start -= 1
        tile_col_end += 1
      else
        tile_col_start += 1
        tile_col_end -= 1
      end
      tile_row += 1
      next
    end
    break if tile_row >= grid.size

    tile_col = tile_col_start
    if tile_col < 0
      tile_col = 0
    end

    actual_end = tile_col_end
    if actual_end >= grid[tile_row].size
      actual_end = grid[tile_row].size - 1
    end

    grid_row = grid[tile_row]
    row_dist = (row - tile_row).abs

    while tile_col <= actual_end
      yield grid_row[tile_col], row_dist + (col - tile_col).abs
      tile_col += 1
    end

    if tile_row < row
      tile_col_start -= 1
      tile_col_end += 1
    else
      tile_col_start += 1
      tile_col_end -= 1
    end

    tile_row += 1
  end
end

# Get the count of all cheats at a given position that are with `distance` tiles
# and save `cheat_min` picoseconds
def cheat_count(pos, grid, cheat_min, distance)
  row, col = pos
  cur_score = grid[row][col]
  cheat_counts = 0

  scan_tiles_in_radius(pos, grid, distance) do |score, dist|
    next unless score

    if (score - cur_score - dist) >= cheat_min
      cheat_counts += 1
    end
  end

  cheat_counts
end

def cheats_for_size(start, grid, cheat_min, distance)
  pos = start
  cheats = 0

  cheats += cheat_count(pos, grid, cheat_min, distance)
  while (pos = next_pos(pos, grid))
    cheats += cheat_count(pos, grid, cheat_min, distance)
  end

  cheats
end

distance = 0
pos = start

while (pos = next_pos(pos, grid))
  distance += 1
  grid[pos[0]][pos[1]] = distance
end

AOC.part1 do
  cheats_for_size(start, grid, 100, 2)
end

AOC.part2 do
  cheats_for_size(start, grid, 100, 20)
end
