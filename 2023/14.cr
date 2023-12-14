require "./aoc"

AOC.day!(14)

enum Tile
  Round
  Cube
  Empty

  def self.new(c : Char)
    case c
    when 'O' then Round
    when '#' then Cube
    when '.' then Empty
    else          raise "'#{c}' is not a valid tile"
    end
  end
end

def roll_rock_north(field, row, col)
  if field[row][col].round?
    move_to_row = row

    while move_to_row > 0 && field[move_to_row - 1][col].empty?
      move_to_row -= 1
    end

    field[row][col] = :empty
    field[move_to_row][col] = :round
  end
end

def roll_rock_west(field, row, col)
  if field[row][col].round?
    move_to_col = col

    while move_to_col > 0 && field[row][move_to_col - 1].empty?
      move_to_col -= 1
    end

    field[row][col] = :empty
    field[row][move_to_col] = :round
  end
end

def roll_north(field)
  (0...(field[0].size)).each do |col|
    (0...field.size).each do |row|
      roll_rock_north(field, row, col)
    end
  end
end

def roll_west(field)
  (0...field.size).each do |row|
    (0...(field[0].size)).each do |col|
      roll_rock_west(field, row, col)
    end
  end
end

def roll_south(field)
  field.reverse!
  roll_north(field)
  field.reverse!
end

def roll_east(field)
  field.each(&.reverse!)
  roll_west(field)
  field.each(&.reverse!)
end

def do_cycle!(field)
  roll_north(field)
  roll_west(field)
  roll_south(field)
  roll_east(field)
end

def measure_load(field)
  (0...field.size).sum do |row|
    cur_load = field.size - row
    field[row].count(&.round?) * cur_load
  end
end

field = AOC.lines.map do |line|
  line.chars.map { |c| Tile.new(c) }
end

AOC.part1 do
  roll_north(field)
  measure_load(field)
end

AOC.part2 do
  # undo the roll from part 1, so we can start part 2 at the beginning of a cycle
  roll_south(field)

  # Keep a copy of the field after each cycle, until we find a repetition
  field_states = [field.clone]

  loop_start = -1
  while true
    do_cycle!(field)

    if (loop_start = field_states.index(field))
      break
    else
      field_states << field.clone
    end
  end

  cur_cycle = field_states.size
  loop_size = cur_cycle - loop_start
  remaining_cycles = (1_000_000_000 - cur_cycle) % loop_size

  end_state = field_states[loop_start + remaining_cycles]
  measure_load(end_state)
end
