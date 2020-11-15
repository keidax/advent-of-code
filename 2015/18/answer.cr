alias Grid = Array(Array(Bool))

def count_neighbors(grid : Grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |light, x|
      num_neighbors = 0
      find_neighbors(grid, x, y) do |neighbor|
        num_neighbors += 1 if neighbor
      end

      yield light, x, y, num_neighbors
    end
  end
end

def find_neighbors(grid : Grid, x, y)
  max_y = grid.size - 1
  max_x = grid[y].size - 1

  [
    {1, 1},
    {1, 0},
    {1, -1},
    {0, -1},
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, 1},
  ].each do |x_off, y_off|
    x_pos = x + x_off
    y_pos = y + y_off

    if (0..max_x).includes?(x_pos) && (0..max_y).includes?(y_pos)
      yield grid[y_pos][x_pos]
    end
  end
end

grid = Array.new(100) { Array(Bool).new(100) { false } }

File.read_lines("input.txt").each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    grid[y][x] = true if char == '#'
  end
end

orig_grid = grid

# Part 1
100.times do
  new_grid = Array.new(100) { Array.new(100) { false } }
  count_neighbors(grid) do |light, x, y, num_neighbors|
    if light
      if (2..3).includes? num_neighbors
        new_grid[y][x] = true
      end
    else
      if num_neighbors == 3
        new_grid[y][x] = true
      end
    end
  end
  grid = new_grid
end

pp grid.sum { |row| row.count &.itself }

# Part 2
grid = orig_grid
100.times do
  new_grid = Array.new(100) { Array.new(100) { false } }
  grid[0][0] = true
  grid[99][0] = true
  grid[99][99] = true
  grid[0][99] = true

  count_neighbors(grid) do |light, x, y, num_neighbors|
    if light
      if (2..3).includes? num_neighbors
        new_grid[y][x] = true
      end
    else
      if num_neighbors == 3
        new_grid[y][x] = true
      end
    end
  end
  grid = new_grid
end

grid[0][0] = true
grid[99][0] = true
grid[99][99] = true
grid[0][99] = true
pp grid.sum { |row| row.count &.itself }
