require_relative "aoc"

input = AOC.day(25)

keys = []
locks = []

input.line_sections.each do |key_or_lock|
  type = if key_or_lock[0] == "....."
    keys
  else
    locks
  end

  columns = key_or_lock.map(&:chars).transpose

  type << columns.map { |col| col.count("#") - 1 }
end

AOC.part1 do
  keys.sum do |key|
    locks.count do |lock|
      (0..4).all? { lock[_1] + key[_1] <= 5 }
    end
  end
end
