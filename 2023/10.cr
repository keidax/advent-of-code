require "./aoc"

AOC.day!(10)

alias Tile = {n: Bool, e: Bool, s: Bool, w: Bool}
alias Pos = {x: Int32, y: Int32}

def parse_tile(c : Char) : Tile
  case c
  when '|' then {n: true, e: false, s: true, w: false}
  when '-' then {n: false, e: true, s: false, w: true}
  when 'L' then {n: true, e: true, s: false, w: false}
  when 'J' then {n: true, e: false, s: false, w: true}
  when '7' then {n: false, e: false, s: true, w: true}
  when 'F' then {n: false, e: true, s: true, w: false}
  when '.' then {n: false, e: false, s: false, w: false}
  when 'S' then {n: true, e: true, s: true, w: true}
  else          raise "no matching tile for '#{c}'"
  end
end

field = AOC.lines.map do |line|
  line.chars.map &->parse_tile(Char)
end

START = parse_tile 'S'

def find_start(field) : Pos
  (0...field.size).each do |y|
    (0...field[y].size).each do |x|
      if field[y][x] == START
        return {x: x, y: y}
      end
    end
  end

  raise "could not find start position"
end

def find_connecting_tiles(field, pos : Pos) : Array(Pos)
  x = pos[:x]
  y = pos[:y]
  tile = field[y][x]

  connected = [] of Pos

  # check north
  if y > 0
    adjacent = field[y - 1][x]
    if tile[:n] && adjacent[:s]
      connected << {x: x, y: y - 1}
    end
  end

  # check south
  if y < field.size - 1
    adjacent = field[y + 1][x]
    if tile[:s] && adjacent[:n]
      connected << {x: x, y: y + 1}
    end
  end

  # check west
  if x > 0
    adjacent = field[y][x - 1]
    if tile[:w] && adjacent[:e]
      connected << {x: x - 1, y: y}
    end
  end

  # check east
  if x < field[y].size - 1
    adjacent = field[y][x + 1]
    if tile[:e] && adjacent[:w]
      connected << {x: x + 1, y: y}
    end
  end

  connected
end

def build_loop(field)
  start = find_start(field)
  # We could go around the loop in 2 directions. It's not really important
  # which, so just pick one of the directions at random
  path, _ = find_connecting_tiles(field, start)
  prev = start

  cycle = [start]

  until path == start
    cycle << path
    options = find_connecting_tiles(field, path)
    path, prev = options.find! { |o| o != prev }, path
  end
  cycle
end

# Travel around the loop in one direction, keeping track of tiles on either
# side of the path. At this point we don't care which is "inside" or "outside".
def build_winding_sets(cycle)
  lhs = Set(Pos).new
  rhs = Set(Pos).new

  (cycle + [cycle[0], cycle[1]]).each_cons(3) do |(prev, curr, nxt)|
    north = {x: curr[:x], y: curr[:y] - 1}
    south = {x: curr[:x], y: curr[:y] + 1}
    east = {x: curr[:x] + 1, y: curr[:y]}
    west = {x: curr[:x] - 1, y: curr[:y]}

    case {prev, nxt}
    when {north, south}
      # |
      # |
      # v
      rhs << west
      lhs << east
    when {north, east}
      # |
      # L>
      rhs << west
      rhs << south
    when {north, west}
      #  |
      # <J
      lhs << east
      lhs << south
    when {south, north}
      # ^
      # |
      # |
      rhs << east
      lhs << west
    when {south, east}
      # F>
      # |
      lhs << west
      lhs << north
    when {south, west}
      # <7
      #  |
      rhs << east
      rhs << north
    when {east, north}
      # ^
      # L-
      lhs << south
      lhs << west
    when {east, south}
      # F-
      # v
      rhs << north
      rhs << west
    when {east, west}
      # <--
      rhs << north
      lhs << south
    when {west, north}
      #  ^
      # -J
      rhs << south
      rhs << east
    when {west, south}
      # -7
      #  v
      lhs << north
      lhs << east
    when {west, east}
      # -->
      rhs << south
      lhs << north
    end
  end

  {lhs, rhs}
end

def clean_set(set, cycle_set, field)
  max_x = field[0].size - 1
  max_y = field.size - 1

  set = set.reject do |pos|
    x, y = pos[:x], pos[:y]

    # We intentionally exclude the x < 0 condition here. If the loop covers every border
    # of the map, then both "inside" and "outside" sets will be in the interior of the
    # field. In that case, we can leave behind some positions with x = -1 to mark the
    # outside set.
    cycle_set.includes?(pos) || y < 0 || x > max_x || y > max_y
  end.to_set
end

def adjacent_pos(field, pos) : Array(Pos)
  adj_pos = [] of Pos

  x = pos[:x]
  y = pos[:y]

  if y > 0
    adj_pos << {x: x, y: y - 1}
  end

  if y < field.size - 1
    adj_pos << {x: x, y: y + 1}
  end

  if x > 0
    adj_pos << {x: x - 1, y: y}
  end

  if x < field[y].size - 1
    adj_pos << {x: x + 1, y: y}
  end

  adj_pos
end

def grow_set(set, cycle_set, field)
  queue = Set(Pos).new(set)

  until queue.empty?
    pos = queue.first
    queue.delete(pos)

    adjacent_pos(field, pos).each do |adjacent|
      next if cycle_set.includes?(adjacent)
      next if set.includes?(adjacent)

      queue << adjacent
      set << adjacent
    end
  end

  set
end

# Check if a set is the "outside" set by seeing if any set elements border or are outside
# the west edge of the field. See also the note in `clean_set`.
def is_outside?(set)
  set.any? { |pos| pos[:x] <= 0 }
end

cycle = build_loop(field)

AOC.part1 do
  cycle.size // 2
end

AOC.part2 do
  lhs, rhs = build_winding_sets(cycle)
  cycle_set = cycle.to_set

  lhs = clean_set(lhs, cycle_set, field)
  rhs = clean_set(rhs, cycle_set, field)

  grow_set(lhs, cycle_set, field)
  grow_set(rhs, cycle_set, field)

  # at this point we still don't know which is the inside set
  if is_outside?(lhs)
    rhs.size
  elsif is_outside?(rhs)
    lhs.size
  else
    puts "one of these is the right answer"
    {rhs.size, lhs.size}
  end
end
