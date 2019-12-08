enum Pixel
  Black
  White
  Unknown
end

input = File.read("./input.txt").chomp

IMAGE_SIZE = 6*25

image = StaticArray(Pixel, IMAGE_SIZE).new(Pixel::Unknown)

input.each_char.each_slice(IMAGE_SIZE).each do |layer|
  layer.each_with_index do |c, i|
    if image[i] == Pixel::Unknown
      image[i] = Pixel.new(c.to_i)
    end
  end
end

image.map_with_index do |p, i|
  print case p
  when Pixel::White
    '#'
  when Pixel::Black
    '_'
  when Pixel::Unknown
    '?'
  end
  if i % 25 == 24
    puts
  end
end
