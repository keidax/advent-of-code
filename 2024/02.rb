require_relative "aoc"

SAFE_RANGE = 1..3

input = AOC.day(2)

reports = input.lines.map do |line|
  line.split.map(&:to_i)
end

report_diffs = reports.map do |report|
  diffs = report.each_cons(2).map do |a, b|
    b - a
  end

  if diffs.count { _1 < 0 } > 2
    # If several diffs are negative, reverse the order. This means we only
    # need to consider the case where levels are increasing.
    diffs.map { |d| d * -1 }.reverse
  else
    diffs
  end
end

def safe?(diffs)
  diffs.all?(SAFE_RANGE)
end

def safe_dampening?(diffs)
  safe?(diffs[1..]) ||
    safe?(diffs[..-2]) ||
    safe_dampen_middle?(diffs)
end

def safe_dampen_middle?(diffs)
  (0..(diffs.size - 2)).each do |i|
    next if SAFE_RANGE.cover?(diffs[i])

    # Removing one level is the same as adding 2 adjacent diffs
    middle = diffs[i] + diffs[i + 1]

    # Confirm the new diff is safe
    return false unless SAFE_RANGE.cover?(middle)

    # Confirm no other levels need to be removed
    rest = diffs[i + 2..]
    return safe?(rest)
  end

  raise "should not be reached"
end

AOC.part1 do
  report_diffs.count { safe?(_1) }
end

AOC.part2 do
  report_diffs.count { safe_dampening?(_1) }
end
