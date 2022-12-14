require "../aoc"
require "json"

AOC.day!(13)

# Alternate implementation:
# Hijack the <=> operator for conciseness

alias PacketData = Int64 | Array(PacketData)

class Array
  def <=>(other : Int64)
    self <=> [other]
  end
end

struct Int64
  def <=>(other : Array(PacketData))
    [self] <=> other
  end
end

struct JSON::Any
  def to_packet_data : PacketData
    raw = self.raw
    case raw
    when Int64 then raw
    when Array then raw.map(&.to_packet_data)
    else
      raise "bad input: #{raw}"
    end
  end
end

packets = AOC.lines.reject("").map do |line|
  JSON.parse(line).to_packet_data
end

AOC.part1 do
  packets.each_slice(2).with_index.sum do |(left, right), i|
    in_order = (left <=> right) < 0
    in_order ? i + 1 : 0
  end
end

divider1 = JSON.parse("[[2]]").to_packet_data
divider2 = JSON.parse("[[6]]").to_packet_data
packets << divider1 << divider2

AOC.part2 do
  packets.sort!
  (packets.index!(divider1) + 1) * (packets.index!(divider2) + 1)
end
