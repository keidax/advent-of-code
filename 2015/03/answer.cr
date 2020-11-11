alias Location = {Int32, Int32}

homes = Hash(Location, Int32).new(default_value = 0)
homes[{0, 0}] += 1

x, y = 0, 0

File.each_line("input.txt") do |line|
  line.each_char do |char|
    case char
    when '^'
      y += 1
    when 'v'
      y -= 1
    when '<'
      x -= 1
    when '>'
      x += 1
    end

    homes[{x, y}] += 1
  end
end

puts homes.keys.size
