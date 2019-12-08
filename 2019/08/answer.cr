input = File.read("./input.txt").chomp

image_size = 6*25

layer_results = input.each_char.each_slice(image_size).map do |layer|
  zero_count = layer.count('0')
  one_count = layer.count('1')
  two_count = layer.count('2')
  next {zero_count, one_count * two_count}
end

puts layer_results.min_by &.[](0)
