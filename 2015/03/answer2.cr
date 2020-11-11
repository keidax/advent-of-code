alias Location = {Int32, Int32}

homes = Hash(Location, Int32).new(default_value = 0)
homes[{0, 0}] += 1

x, y = 0, 0
robo_x, robo_y = 0, 0

is_robo = false

File.each_line("input.txt") do |line|
  line.each_char do |char|
    if is_robo
      case char
      when '^'
        robo_y += 1
      when 'v'
        robo_y -= 1
      when '<'
        robo_x -= 1
      when '>'
        robo_x += 1
      end
    else
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
    end

    if is_robo
      homes[{robo_x, robo_y}] += 1
    else
      homes[{x, y}] += 1
    end

    is_robo = !is_robo
  end
end

puts homes.keys.size
