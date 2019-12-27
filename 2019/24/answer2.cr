require "bit_array"

require "../expect"

expect "Example 1", {<<-BUGS, 10}, 99
....#
#..#.
#..##
..#..
#....
BUGS

puts answer File.read("input.txt"), 200

def answer(input : String, minutes)
  bugs = BitArray.new(25)
  input.delete('\n').chars.map_with_index do |c, i|
    bugs[i] = true if c == '#'
  end

  # Set up initial levels with an empty one above and below
  levels = Deque(BitArray).new(initial_capacity: 3)
  levels << BitArray.new(25)
  levels << bugs
  levels << BitArray.new(25)

  minutes.times do
    levels = update_bugs(levels)
    puts bug_count(levels)
  end

  # levels.each_with_index do |level, i|
  #   puts "Level #{i}:"
  #   show_bugs(level)
  # end

  bug_count(levels)
end

def update_bugs(bug_levels)
  new_levels = bug_levels.map_with_index do |_, i|
    update_bugs(bug_levels, i)
  end

  if bug_count(new_levels.last) > 0
    new_levels << BitArray.new(25)
  end

  if bug_count(new_levels.first) > 0
    new_levels.unshift(BitArray.new(25))
  end

  new_levels
end

def update_bugs(all_levels : Indexable(BitArray), level_index : Int) : BitArray
  level = all_levels[level_index]

  next_level = BitArray.new(level.size)

  level.each_with_index do |bug, i|
    row = i // 5
    col = i % 5

    next if i == 12

    neighbors = neighbor_bugs(all_levels, level_index, row, col)
    if bug && neighbors == 1
      next_level[i] = true
    elsif !bug && (1..2).includes?(neighbors)
      next_level[i] = true
    end
  end

  next_level
end

@[AlwaysInline]
def get_bug(bugs, row, col)
  bugs[row * 5 + col]
end

@[AlwaysInline]
def neighbor_bugs(bug_levels, level_index, row, col)
  count = 0
  current_level = bug_levels[level_index]

  # Make sure this is safe for highest/lowest levels
  if level_index > 0
    outer_level = bug_levels[level_index - 1]
  else
    outer_level = BitArray.new(25)
  end
  if level_index + 1 < bug_levels.size
    inner_level = bug_levels[level_index + 1]
  else
    inner_level = BitArray.new(25)
  end

  if col > 0
    if col == 3 && row == 2
      count += col_sum(inner_level, 4)
    elsif get_bug(current_level, row, col - 1)
      count += 1
    end
  elsif get_bug(outer_level, 2, 1)
    count += 1
  end

  if row > 0
    if row == 3 && col == 2
      count += row_sum(inner_level, 4)
    elsif get_bug(current_level, row - 1, col)
      count += 1
    end
  elsif get_bug(outer_level, 1, 2)
    count += 1
  end

  if col < 4
    if col == 1 && row == 2
      count += col_sum(inner_level, 0)
    elsif get_bug(current_level, row, col + 1)
      count += 1
    end
  elsif get_bug(outer_level, 2, 3)
    count += 1
  end

  if row < 4
    if row == 1 && col == 2
      count += row_sum(inner_level, 0)
    elsif get_bug(current_level, row + 1, col)
      count += 1
    end
  elsif get_bug(outer_level, 3, 2)
    count += 1
  end

  count
end

def row_sum(bug_level, row)
  bug_level[(row * 5), 5].count(true)
end

def col_sum(bug_level, col)
  (col..(20 + col)).step(5).sum do |i|
    if bug_level[i]
      1
    else
      0
    end
  end
end

def show_bugs(bugs)
  bugs.each_slice(5).with_index do |bug_row, r|
    bug_row.each_with_index do |bug, c|
      char = if r == 2 && c == 2
               '?'
             elsif bug
               '#'
             else
               '.'
             end
      print(char)
    end
    puts
  end
end

def bug_count(level : BitArray)
  level.count(true)
end

def bug_count(levels : Enumerable(BitArray))
  levels.sum &->bug_count(BitArray)
end
