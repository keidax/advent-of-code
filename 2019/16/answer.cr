input = File.read("input.txt").chomp

data = input.each_char.map(&.to_i).to_a

100.times do
  data = data.map_with_index do |_, digit|
    sum = 0
    data.each_with_index do |d, i|
      acc = ((i - digit) // (digit + 1)) % 4
      if acc == 0
        sum += d
      elsif acc == 2
        sum -= d
      end
    end
    sum.abs % 10
  end
  print '.'
end
puts

puts data.first(8).join ""
