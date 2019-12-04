#!/usr/bin/env ruby

count2 = 0
count3 = 0

while (line = gets&.chomp)
  char_counts = Hash.new(0)
  line.each_char do |c|
    char_counts[c] += 1
  end

  vals = char_counts.values
  if vals.any? { |v| v == 2 }
    count2 += 1
  end

  if vals.any? { |v| v == 3 }
    count3 += 1
  end
end

puts count2 * count3
