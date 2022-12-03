require "../aoc"

AOC.day!(3)

rucksacks = [] of String

AOC.each_line do |line|
  rucksacks << line
end

def get_common_item(compartment1, compartment2)
  common = compartment1.chars & compartment2.chars

  unless common.size == 1
    raise "expected exactly 1 common item between #{compartment1} and #{compartment2}, got #{common}"
  end

  common[0]
end

def item_priority(item)
  case item
  when 'a'..'z'
    (item - 'a') + 1
  when 'A'..'Z'
    (item - 'A') + 27
  else
    raise "unexpected item '#{item}'"
  end
end

AOC.part1 do
  rucksacks
    .map { |r|
      compartment_size = r.size // 2
      get_common_item(r[0...compartment_size], r[compartment_size..-1])
    }
    .map { |i| item_priority(i) }
    .sum
end

AOC.part2 do
  rucksacks
    .in_groups_of(3, "")
    .map { |chunk| chunk[0].chars & chunk[1].chars & chunk[2].chars }
    .map { |items| item_priority(items[0]) }
    .sum
end
