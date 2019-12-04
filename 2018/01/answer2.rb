#!/usr/bin/env ruby

require 'set'

sum = 0
freqs = Set[0]
list = []

while (line = gets&.chomp)
  sign = line[0]
  num = line[1..-1].to_i

  list << if sign == '+'
    num
  else
    -num
  end
end

while true
  for i in list
    sum += i
    if freqs.include? sum
      puts sum
      exit
    end

    freqs << sum
  end
end
