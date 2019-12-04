#!/usr/bin/env ruby

SERIAL = ARGV[0].to_i

fuel_cells = Array.new(300) { Array.new(300, nil) }

def power_level(x, y)
  # puzzle coords start at 1, 1
  x += 1
  y += 1

  rack_id = x + 10
  power = rack_id * y
  power += SERIAL
  power *= rack_id
  power = power.digits[2]
  power - 5
end

def sum_of_region(cells, x, y)
  sum = 0
  x.upto(x + 2).each do |x|
    y.upto(y + 2).each do |y|
      sum += cells[x][y]
    end
  end
  sum
end

(0...300).each do |x|
  (0...300).each do |y|
    fuel_cells[x][y] = power_level(x, y)
  end
end

max = -30
max_pos = [0, 0]
(0..297).each do |x|
  (0..297).each do |y|
    cur_sum = sum_of_region(fuel_cells, x, y)
    if cur_sum > max
      max = cur_sum
      max_pos = [x + 1, y + 1]
    end
  end
end

pp max_pos
