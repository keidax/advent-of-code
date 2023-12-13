require "./aoc"

AOC.day!(12)

spring_rows = AOC.lines.map do |line|
  springs, damage_groups = line.split " "

  damage_groups = damage_groups.split(",").map(&.to_i)

  {springs, damage_groups}
end

# Cache arrangement counts for different substrings and groupings
CACHE = {} of {String, Array(Int32)} => Int64

# Cache these regular expressions instead of creating them over and over again
RE_CACHE = {} of Int32 => Regex

def load_regex(group_size)
  RE_CACHE[group_size] ||= /([?#]{#{group_size}})(\?|\.|$)/
end

# A recursive algorithm to count all valid arrangements of springs. We start by
# considering the first group. For each valid position of that group, we count up the
# arrangements for the rest of the string and remaining groups.
def count_arrangements(springs : String, groups : Array(Int32)) : Int64
  cache_key = {springs, groups}

  if (res = CACHE[cache_key]?)
    return res
  end

  if groups.empty?
    if springs.index('#')
      # All of the groups have been matched but we missed a required position.
      CACHE[cache_key] = 0
      return 0i64
    else
      # All groups are matched, and we have no required positions left. This counts as one
      # valid arrangement.
      CACHE[cache_key] = 1
      return 1i64
    end
  elsif springs.empty?
    # There are remaining groups to match, but no springs left. This is a miss.
    CACHE[cache_key] = 0
    return 0i64
  end

  cur_group, *remaining_groups = groups

  counts = 0i64

  # Starting from the beginning of the string, find each possible position for the next
  # group of springs. Treat the first '#' as the upper limit of the search, because this
  # position must be a spring and we can't skip it.
  regex = load_regex(cur_group)
  search_pos = 0
  search_limit = springs.index('#') || (springs.bytesize - 1)

  while search_pos <= search_limit
    if springs.match(regex, search_pos)
      md = $~

      if md.byte_begin > search_limit
        # This match skipped a '#', so it doesn't count.
        break
      end

      # Advance the start of the next search by one.
      search_pos = md.byte_begin + 1

      remaining = md.post_match
      counts += count_arrangements(remaining, remaining_groups)
    else
      # No more matches
      break
    end
  end

  CACHE[cache_key] = counts
  counts
end

def unfold_input(spring_rows, multiplier)
  spring_rows.map do |(springs, groups)|
    {([springs] * multiplier).join('?'), groups * multiplier}
  end
end

AOC.part1 do
  spring_rows.sum { |r| count_arrangements(*r) }
end

AOC.part2 do
  unfold_input(spring_rows, 5).sum { |r| count_arrangements(*r) }
end
