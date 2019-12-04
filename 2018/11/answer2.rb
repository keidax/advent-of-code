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

def sum_of_region(cells, x, y, size:)
  sum = 0
  x.upto(x + size - 1).each do |x|
    y.upto(y + size - 1).each do |y|
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
max_size = 1

Signal.trap 'INT' do
  puts "max so far: #{max} @ #{max_pos}, #{max_size}"
  exit
end

(1..300).each do |size|
  (0..(300 - size)).each do |x|
    (0..(300 - size)).each do |y|
      cur_sum = sum_of_region(fuel_cells, x, y, size: size)
      if cur_sum > max
        max = cur_sum
        max_pos = [x + 1, y + 1]
        max_size = size
      end
    end
  end

  puts "max for size #{size} is #{max}"
end

pp max_pos, max_size
