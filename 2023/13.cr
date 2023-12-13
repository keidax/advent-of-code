require "./aoc"

AOC.day!(13)

mirrors = AOC.lines.slice_after("").map do |section|
  # clean out the blank lines
  section.reject("")
end.to_a

# Find a mirror row that gives a reflection with the given number of smudges
def find_reflecting_row(mirror, target_mismatch)
  (0...(mirror.size - 1)).each do |r|
    row_mismatch = check_row_reflection(mirror, r)
    if row_mismatch == target_mismatch
      return r + 1
    end
  end
end

# Return the number of smudges when reflecting at the given row. Will return 0 if the
# reflection is perfect, 1 if a single character needs to be changed for a perfect
# reflection, etc.
def check_row_reflection(mirror, row)
  (0..row).sum do |offset|
    upper = row - offset
    lower = row + offset + 1

    if lower >= mirror.size
      # The reflected row is out of bounds, so we assume it's a perfect match.
      next 0
    end

    mismatched_chars = 0

    mirror[upper].each_char_with_index do |c, i|
      if mirror[lower][i] != c
        mismatched_chars += 1
      end
    end

    mismatched_chars
  end
end

def find_reflecting_col(mirror, mismatch)
  flipped = mirror.map(&.chars).transpose.map(&.join(""))
  find_reflecting_row(flipped, mismatch)
end

def summarize_reflections(mirrors, mismatch)
  rows = mirrors.map { |m| find_reflecting_row(m, mismatch) }.compact.sum
  cols = mirrors.map { |m| find_reflecting_col(m, mismatch) }.compact.sum
  cols + 100*rows
end

AOC.part1 { summarize_reflections(mirrors, mismatch: 0) }
AOC.part2 { summarize_reflections(mirrors, mismatch: 1) }
