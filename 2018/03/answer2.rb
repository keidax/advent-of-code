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

  def apply(fabric)
    for x in (self.x...self.x+self.w)
      for y in (self.y...self.y+self.h)
        fabric[x][y] += 1
      end
    end
  end

  def overlap?(fabric)
    for x in (self.x...self.x+self.w)
      for y in (self.y...self.y+self.h)
        return true if fabric[x][y] > 1
      end
    end

    false
  end
end

fabric = Array.new(1000) { Array.new(1000, 0) }
claims = []

while (line = gets&.chomp)
  claim = Claim.new(line)
  claim.apply fabric
  claims << claim
end

claims.each do |claim|
  next if claim.overlap? fabric
  puts claim.id
  exit
end
