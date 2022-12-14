require "../aoc"
require "json"

AOC.day!(13)

packet_pairs = AOC.lines.each_slice(3).map do |slice|
  left = JSON.parse(slice[0])
  right = JSON.parse(slice[1])

  [left, right]
end.to_a

def ordered?(left : JSON::Any, right : JSON::Any)
  ordered?(left.raw, right.raw)
end

def ordered?(left : Int64, right : Int64)
  if left < right
    true
  elsif right < left
    false
  else
    nil
  end
end

def ordered?(left : Array(JSON::Any), right : Array(JSON::Any))
  left.zip?(right) do |l, r|
    if r.nil?
      # right list ran out of items first, not in order
      return false
    end

    res = ordered?(l.raw, r.raw)
    return res if !res.nil?
  end

  if left.size < right.size
    true
  else
    # lists must be equal size
    nil
  end
end

def ordered?(left : Array(JSON::Any), right : Int)
  ordered?(left, [JSON::Any.new(right)])
end

def ordered?(left : Int, right : Array(JSON::Any))
  ordered?([JSON::Any.new(left)], right)
end

def ordered?(left, right)
  p! left, right
  raise "unexpected call with left = #{typeof(left)} and right = #{typeof(right)}"
end

AOC.part1 do
  packet_pairs.map_with_index do |pair, i|
    if ordered?(pair[0], pair[1])
      i + 1
    else
      0
    end
  end.sum
end

AOC.part2 do
  packets = packet_pairs.flatten

  divider1, divider2 = JSON.parse("[[2]]"), JSON.parse("[[6]]")
  packets << divider1 << divider2

  packets.sort! do |l, r|
    case ordered?(l, r)
    when true  then -1
    when nil   then 0
    when false then 1
    end
  end

  (packets.index!(divider1) + 1) * (packets.index!(divider2) + 1)
end
