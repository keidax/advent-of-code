#!/usr/bin/env ruby

require 'pp'

class Claim
  attr_accessor :id, :x, :y, :w, :h

  def initialize(string)
    match = string.match(/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/)

    self.id,
    self.x,
    self.y,
    self.w,
    self.h = match[1..-1].map(&:to_i)
  end
end

fabric = Array.new(1000) { Array.new(1000, 0) }

while (line = gets&.chomp)
  claim = Claim.new(line)

  for x in (claim.x...claim.x+claim.w)
    for y in (claim.y...claim.y+claim.h)
      fabric[x][y] += 1
    end
  end
end

overclaimed = 0

for line in fabric
  for inch in line
    overclaimed += 1 if inch > 1
  end
end

puts overclaimed
