require "../aoc"

AOC.day! 14

rocks = AOC.lines.map { |line|
  line.split(" -> ")
    .map { |coords| coords.split(",").map(&.to_i) }
    .map { |coords| Tuple(Int32, Int32).from(coords) }
}

enum Block
  Air
  Rock
  Sand
end

max_y = rocks.flatten.map(&.[1]).max + 2
max_x = 1000 # This isn't exact, but it should leave enough room

cave = Array.new(size: max_y) {
  Array(Block).new(size: max_x, value: Block::Air)
}

rocks.each do |path|
  path.each_cons_pair do |(x1, y1), (x2, y2)|
    xmin, xmax = {x1, x2}.minmax
    ymin, ymax = {y1, y2}.minmax

    (xmin..xmax).each do |x|
      (ymin..ymax).each do |y|
        cave[y][x] = Block::Rock
      end
    end
  end
end

def add_sand(cave, has_floor = false)
  max_y = cave.size

  x = 500
  y = 0

  if cave[y][x] == Block::Sand
    # blocked
    return false
  end

  loop do
    case
    when y + 1 == max_y
      if has_floor
        # come to rest
        cave[y][x] = Block::Sand
        return true
      else
        # the abyss
        return false
      end
    when cave[y + 1][x] == Block::Air
      # fall down
      y += 1
    when cave[y + 1][x - 1] == Block::Air
      # fall down and left
      y += 1
      x -= 1
    when cave[y + 1][x + 1] == Block::Air
      # fall down and right
      y += 1
      x += 1
    else
      # come to rest
      cave[y][x] = Block::Sand
      return true
    end
  end
end

grains = 0

AOC.part1 do
  while add_sand(cave, has_floor: false)
    grains += 1
  end
  grains
end

AOC.part2 do
  while add_sand(cave, has_floor: true)
    grains += 1
  end
  grains
end
