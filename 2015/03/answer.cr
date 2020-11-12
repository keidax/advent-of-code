alias Location = {Int32, Int32}

class Santa
  property x = 0
  property y = 0

  def initialize(@homes : Hash(Location, Int32))
  end

  def visit
    @homes[{x, y}] += 1
  end
end

# Part 1
homes = Hash(Location, Int32).new(default_value = 0)
homes[{0, 0}] += 1

santa = Santa.new(homes)

File.each_line("input.txt") do |line|
  line.each_char do |char|
    case char
    when '^'
      santa.y += 1
    when 'v'
      santa.y -= 1
    when '<'
      santa.x -= 1
    when '>'
      santa.x += 1
    end

    santa.visit
  end
end

puts homes.keys.size

# Part 2
homes = Hash(Location, Int32).new(default_value = 0)
homes[{0, 0}] += 1

# both santas share the same homes
santa = Santa.new(homes)
robo_santa = Santa.new(homes)

File.each_line("input.txt") do |line|
  line.each_char do |char|
    case char
    when '^'
      santa.y += 1
    when 'v'
      santa.y -= 1
    when '<'
      santa.x -= 1
    when '>'
      santa.x += 1
    end

    santa.visit
    santa, robo_santa = robo_santa, santa
  end
end

puts homes.keys.size
