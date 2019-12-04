#!/usr/bin/env ruby

class Point
  attr_accessor :position, :velocity

  def initialize(string)
    match = string.match(/position=<(\s*-?\d+),(\s*-?\d+)> velocity=<(\s*-?\d+),(\s*-?\d+)>/)

    self.position = match[1, 2].map(&:to_i)
    self.velocity = match[3, 4].map(&:to_i)
  end

  def tick
    position[0] += velocity[0]
    position[1] += velocity[1]
  end
end

def get_minimum(points)
  y_vals = points.map(&:position).map(&:last)
  y_vals.max - y_vals.min
end


def print_points(points)
  x_vals = points.map(&:position).map(&:first)
  y_vals = points.map(&:position).map(&:last)

  min_x = x_vals.min
  min_y = y_vals.min

  x_vals.map! { |x| x - min_x }
  y_vals.map! { |y| y - min_y }

  max_x = x_vals.max + 3
  max_y = y_vals.max + 3

  matrix = Array.new(max_y) { Array.new(max_x, nil) }

  x_vals.zip(y_vals).each do |x, y|
    matrix[y][x] = true
  end

  matrix.each do |line|
    line.each do |char|
      print char ? '#' : '.'
    end
    puts
  end
end

points = []
while (line = gets&.chomp)
  points << Point.new(line)
end

second_at_minimum = 0
minimum = get_minimum(points)

12000.times do |second|
  cur_min = get_minimum(points)

  if cur_min < minimum
    minimum = cur_min
    second_at_minimum = second

    if minimum == 9
      print_points(points)
    end
  end

  points.each(&:tick)
end
