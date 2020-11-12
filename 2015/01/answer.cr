# Part 1
floor = 0
File.each_line("input.txt") do |line|
  line.each_char do |char|
    case char
    when '('
      floor += 1
    when ')'
      floor -= 1
    end
  end
end
puts floor

# Part 2
floor = 0
char_pos = 0
File.each_line("input.txt") do |line|
  line.each_char do |char|
    char_pos += 1
    case char
    when '('
      floor += 1
    when ')'
      floor -= 1
      if floor < 0
        puts char_pos
        exit
      end
    end
  end
end
