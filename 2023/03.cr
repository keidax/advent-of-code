require "./aoc"

AOC.day!(3)

# We can't call this Symbol because that's a builtin Crystal type
alias EngineSym = {row: Int32, col: Int32, sym: Char}
alias PartNum = {row: Int32, cols: Range(Int32, Int32), num: Int32}

PART_NUMS = [] of PartNum
SYMBOLS   = [] of EngineSym

def load_part_numbers!
  AOC.lines.each_with_index do |line, row|
    line.scan(/(\d+)/) do |num_match|
      num = num_match[0].to_i
      PART_NUMS << {
        row: row.to_i,
        # Expand the column range to include adjacent columns, to simplify the logic later
        cols: num_match.begin - 1..num_match.end,
        num:  num,
      }
    end
  end
end

def load_symbols!
  AOC.lines.each_with_index do |line, row|
    line.scan(/[^\d.]/) do |sym_match|
      sym = sym_match[0].chars[0]
      SYMBOLS << {
        row: row.to_i,
        col: sym_match.begin,
        sym: sym,
      }
    end
  end
end

def find_adjacent_numbers(sym : EngineSym) : Array(PartNum)
  min_row = sym[:row] - 1
  max_row = sym[:row] + 1

  # We can use binary search, since PART_NUMS is sorted by row.
  start_i = PART_NUMS.bsearch_index { |num| num[:row] >= min_row } || PART_NUMS.size
  end_i = PART_NUMS.bsearch_index { |num| num[:row] > max_row } || nil

  # Note: end_i is treated as exclusive -- it's the first index _beyond_ the
  # range of the current rows
  PART_NUMS[start_i...end_i].select { |num| num[:cols].includes?(sym[:col]) }
end

load_part_numbers!
load_symbols!

AOC.part1 do
  # This assumes that every number is adjacent to one symbol at most
  SYMBOLS.flat_map(&->find_adjacent_numbers(EngineSym)).sum(&.[:num])
end

AOC.part2 do
  SYMBOLS
    .select { |sym| sym[:sym] == '*' }
    .map { |sym| find_adjacent_numbers(sym) }
    .select { |nums| nums.size == 2 }
    .sum { |nums| nums[0][:num] * nums[1][:num] }
end
