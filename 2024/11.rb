require_relative "aoc"

input = AOC.day(11)

stones = input.lines(chomp: true)[0].split(" ").map(&:to_i)

# Memoize how many stones a stone becomes after N blinks.
# This is likely not the most efficient cache structure (a lot of intermediate
# work is thrown away) but it's easily fast enough for Part 2.
blink_cache = Hash.new do |h_blink, blink|
  h_blink[blink] = Hash.new do |h_stone, stone|
    h_stone[stone] = stone_after_blinks(stone, blink, blink_cache)
  end
end

def stone_after_blinks(stone, blinks, cache)
  if blinks == 0
    return 1
  end

  next_cache = cache[blinks - 1]

  if stone == 0
    next_cache[1]
  elsif (s = stone.to_s).size.even?
    left = s[...(s.size / 2)].to_i
    right = s[(s.size / 2)...].to_i

    next_cache[left] + next_cache[right]
  else
    next_cache[stone * 2024]
  end
end

AOC.part1 do
  stones.sum { stone_after_blinks(_1, 25, blink_cache) }
end

AOC.part2 do
  stones.sum { stone_after_blinks(_1, 75, blink_cache) }
end
