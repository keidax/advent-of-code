#!/usr/bin/env ruby

sum = 0

while (line = gets&.chomp)
  sign = line[0]
  num = line[1..-1].to_i

  if sign == '+'
    sum += num
  else
    sum -= num
  end
end

puts sum
