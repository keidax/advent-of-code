input_lines = File.read_lines("input.txt")

rows = input_lines.size
cols = input_lines.first.size

# Fill out data
array = Array.new(rows) { Array.new(cols) { false } }
input_lines.each_with_index do |line, i|
  line.each_char.with_index do |char, j|
    if char == '#'
      array[i][j] = true
    end
  end
end

# Calculate all possible directional offsets
# In other words, the set of all coordinates that are relatively prime to each other
alias Offset = Tuple(Int32, Int32)
offsets = [] of Offset
sieve = Array.new(rows) { Array.new(cols) { false } }
sieve[0][0] = true
rows.times do |i|
  cols.times do |j|
    next if sieve[i][j]

    sieve[i][j] = true
    offsets << Offset.new(i, j)

    x, y = i, j

    while x < rows && y < cols
      sieve[x][y] = true
      x += i
      y += j
    end
  end
end

# Rotate offsets in other 3 quadrants
directions = [
  {1, -1},
  {-1, -1},
  {-1, 1},
]
flipped = [] of Offset
offsets.each do |off|
  directions.each do |(dir_x, dir_y)|
    flipped << Offset.new(off[0] * dir_x, off[1] * dir_y)
  end
end

# uniq so we don't count the offsets in cardinal directions twice
offsets.concat(flipped).uniq!

def count_visible(array, x, y, offsets)
  offsets.count do |offset|
    find_in_direction(array, x, y, offset)
  end
end

def find_in_direction(array, x, y, offset) : {Int32, Int32}?
  rows = array.size
  cols = array.first.size

  off_x, off_y = offset
  x += off_x
  y += off_y

  while (0...rows).includes?(y) && (0...cols).includes?(x)
    if array[y][x] == true
      return {x, y}
    end

    x += off_x
    y += off_y
  end
end

max_visible = 0
position = {0, 0}

rows.times do |y|
  cols.times do |x|
    # Order is flipped from what the puzzle considers X, Y
    next unless array[y][x]

    visible = count_visible(array, x, y, offsets)

    if visible > max_visible
      max_visible = visible
      position = {x, y}
    end
  end
end

puts position
puts max_visible
