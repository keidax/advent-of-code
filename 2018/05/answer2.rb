#!/usr/bin/env ruby

def react(poly)
  stack = []

  while poly.size > 1
    a = poly.shift
    b = poly[0]
    if a == b.swapcase
      # delete these two, and shift back one
      poly.shift
      unless stack.empty?
        poly.unshift(stack.pop)
      end
    else
      stack << a
    end
  end

  stack.concat(poly) if poly.size == 1

  stack
end

poly = gets.chomp
min = poly.size

('a'..'z').each do |char|
  new_poly = poly.gsub(/#{char}/i, '')
  min = [
    min,
    react(new_poly.each_char.to_a).size
  ].min
end

puts min
