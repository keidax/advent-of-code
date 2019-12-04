#!/usr/bin/env ruby

def react(poly)
  puts "reacting polymer of size #{poly.size}"
  new_poly = ''
  skip_next = false
  poly.each_char.each_cons(2) do |a, b|
    if skip_next
      skip_next = false
      next
    end

    if a == b.swapcase
      skip_next = true
      next
    end

    new_poly << a
  end

  unless skip_next
    new_poly << poly[-1]
  end

  new_poly
end

poly = gets.chomp

new_poly = react(poly)

until new_poly == poly
  poly, new_poly = new_poly, react(new_poly)
end

puts poly
puts poly.size
