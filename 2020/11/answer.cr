enum Seat
  Floor
  Empty
  Occupied
end

grid = Array(Array(Seat)).new

File.each_line("input.txt") do |line|
  row = line.chars.map do |c|
    case c
    when '.'
      Seat::Floor
    when 'L'
      Seat::Empty
    else
      raise "unexpected position '#{c}'"
    end
  end
  grid << row
end

def adjacent_seats(grid, row, col) : Array(Seat)
  [
    {+1, +0},
    {+1, +1},
    {+0, +1},
    {-1, +1},
    {-1, +0},
    {-1, -1},
    {+0, -1},
    {+1, -1},
  ].map do |r_off, c_off|
    next unless (0...grid.size).includes?(row + r_off)
    next unless (0...grid[row].size).includes?(col + c_off)

    grid[row + r_off][col + c_off]
  end.compact
end

def visible_seats(grid, row, col) : Array(Seat)
  seats = [
    {+1, +0},
    {+1, +1},
    {+0, +1},
    {-1, +1},
    {-1, +0},
    {-1, -1},
    {+0, -1},
    {+1, -1},
  ].map do |r_off, c_off|
    seat_in_direction(grid, row, col, r_off, c_off)
  end

  seats.compact
end

def seat_in_direction(grid, row, col, row_off, col_off) : Seat?
  distance = 1
  while (0...grid.size).includes?(row + row_off * distance) &&
        (0...grid[row].size).includes?(col + col_off * distance)
    seat = grid[row + row_off * distance][col + col_off * distance]

    if seat.floor?
      distance += 1
    else
      return seat
    end
  end
end

def next_round(grid, max_occupied, &find_seats)
  next_grid = grid.clone

  (0...grid.size).each do |row|
    (0...grid[row].size).each do |col|
      seat = grid[row][col]
      adjacent = yield grid, row, col

      if seat.empty? && adjacent.none?(&.occupied?)
        next_grid[row][col] = :occupied
      end

      if seat.occupied? && adjacent.count(&.occupied?) >= max_occupied
        next_grid[row][col] = :empty
      end
    end
  end

  next_grid
end

def find_stable_state(grid)
  loop do
    next_grid = yield grid
    return grid if next_grid == grid
    grid = next_grid
  end
end

# Part 1
stable = find_stable_state(grid) do |grid|
  next_round(grid, max_occupied: 4) do |grid, row, col|
    adjacent_seats(grid, row, col)
  end
end
puts stable.sum(&.count(&.occupied?))

# Part 2
stable = find_stable_state(grid) do |grid|
  next_round(grid, max_occupied: 5) do |grid, row, col|
    visible_seats(grid, row, col)
  end
end

puts stable.sum(&.count(&.occupied?))
