lines = [] of Int32
File.each_line("input.txt") do |line|
    lines << line.to_i
end

sum = lines.map do |i|
    (i / 3).floor - 2
end.sum

puts sum

