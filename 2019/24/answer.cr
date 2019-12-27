require "bit_array"

require "../expect"

expect "Example 1", {<<-BUGS}, 2129920
....#
#..#.
#..##
..#..
#....
BUGS

puts answer File.read("input.txt")

def answer(input : String)
  bugs = BitArray.new(25)
  input.delete('\n').chars.map_with_index do |c, i|
    bugs[i] = true if c == '#'
  end

  bug_map = Set(BitArray).new
  bug_map << bugs

  loop do
    bugs = update_bugs(bugs)

    if bug_map.includes?(bugs)
      puts bug_map.size
      show_bugs bugs

      return biodiversity(bugs)
    end

    bug_map << bugs
  end

  0_u32
end

def update_bugs(bugs)
  next_bugs = BitArray.new(bugs.size)

  bugs.each_with_index do |bug, i|
    row = i // 5
    col = i % 5

    neighbors = neighbor_bugs(bugs, row, col)
    if bug && neighbors == 1
      next_bugs[i] = true
    elsif !bug && (1..2).includes?(neighbors)
      next_bugs[i] = true
    end
  end

  next_bugs
end

@[AlwaysInline]
def get_bug(bugs, row, col)
  bugs[row * 5 + col]
end

@[AlwaysInline]
def neighbor_bugs(bugs, row, col)
  count = 0

  if col > 0 && get_bug(bugs, row, col - 1)
    count += 1
  end
  if row > 0 && get_bug(bugs, row - 1, col)
    count += 1
  end
  if col < 4 && get_bug(bugs, row, col + 1)
    count += 1
  end
  if row < 4 && get_bug(bugs, row + 1, col)
    count += 1
  end

  count
end

def show_bugs(bugs)
  bugs.each_slice(5) do |bug_row|
    bug_row.each do |bug|
      print(if bug
        '#'
      else
        '.'
      end)
    end
    puts
  end
end

def biodiversity(bugs)
  score = 0
  tile_score = 1

  bugs.each do |bug|
    if bug
      score += tile_score
    end

    tile_score *= 2
  end

  score
end
