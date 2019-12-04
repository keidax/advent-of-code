#!/usr/bin/env ruby

class Coord
  attr_accessor :x, :y

  def initialize(string)
    match = string.match(/(\d+), (\d+)/)
    self.x, self.y = match[1, 2].map(&:to_i)
  end

  def distance(*args)
    if args.size == 1
      other = args[0]
      (other.x - x).abs + (other.y - y).abs
    elsif args.size == 2
      (args[0] - x).abs + (args[1] - y).abs
    end
  end

  # Returns the quadrant(s) other entry is in, relative to this one:
  #
  #     \  up   /
  #      \  |  /
  #       \ | /
  #        \|/
  # - left --- right -
  #        /|\
  #       / | \
  #      /  |  \
  #     / down  \
  #
  # If the other entry is on a quadrant boundary, both will be returned

  def quadrant(other)
    quads = []
    offset = [other.x - x, other.y - y]

    return quads if offset == [0, 0]

    closer_to_horizontal = offset[0].abs >= offset[1].abs
    closer_to_vertical = offset[0].abs <= offset[1].abs

    quads << :right if offset[0] >= 0 && closer_to_horizontal

    quads << :left  if offset[0] <= 0 && closer_to_horizontal

    quads << :up    if offset[1] >= 0 && closer_to_vertical

    quads << :down  if offset[1] <= 0 && closer_to_vertical

    quads
  end

  # x_entries: entries sorted left-to-right
  # y_entries: entries sorted bottom-to-top
  def infinite?(x_entries, y_entries)
    !(
      any_in_quad?(y_entries, :up) &&
      any_in_quad?(y_entries, :down) &&
      any_in_quad?(x_entries, :left) &&
      any_in_quad?(x_entries, :right)
    )
  end

  def any_in_quad?(entries, quad)
    condition, start_of_range = case quad
    when :up    then [proc { |e| e.y > y }, true]
    when :down  then [proc { |e| e.y > y }, false]
    when :left  then [proc { |e| e.x > x }, false]
    when :right then [proc { |e| e.x > x }, true]
    end

    cutoff = entries.bsearch_index(&condition)
    return false unless cutoff

    possible = entries[start_of_range ? cutoff..-1 : 0..cutoff]
    possible.any? { |e| quadrant(e).include?(quad) }
  end

  def self.nearest(x, y, entries)
    nearest = entries.min_by(2) { |e| e.distance(x, y) }

    if nearest[0].distance(x, y) < nearest[1].distance(x, y)
      nearest[0]
    end
  end
end

entries = []

while (line = gets&.chomp)
  entries << Coord.new(line)
end

xs = entries.map &:x
ys = entries.map &:y

x_range = (xs.min - 210)..(xs.max + 210)
y_range = (ys.min - 210)..(ys.max + 210)

region = 0
for x in x_range
  for y in y_range
    catch :overflow do
      sum = 0
      for entry in entries
        sum += entry.distance(x, y)
        throw :overflow if sum >= 10_000
      end
      region += 1
    end
  end
end

puts region
