require "../aoc"

AOC.day!(23)

enum Direction
  North
  South
  West
  East
end

class Elf
  @@map = {} of {Int32, Int32} => self

  def self.all
    @@map.values
  end

  def self.at?(location)
    @@map[location]?
  end

  @location : {Int32, Int32}

  def initialize(@location)
    @@map[@location] = self
  end

  def location=(new_loc)
    @@map.delete(@location)
    @location = new_loc
    @@map[@location] = self
  end

  def location
    @location
  end

  def propose_move(directions)
    x, y = @location

    n = Elf.at?({x, y - 1})
    ne = Elf.at?({x + 1, y - 1})
    e = Elf.at?({x + 1, y})
    se = Elf.at?({x + 1, y + 1})
    s = Elf.at?({x, y + 1})
    sw = Elf.at?({x - 1, y + 1})
    w = Elf.at?({x - 1, y})
    nw = Elf.at?({x - 1, y - 1})

    return nil if !(n || ne || e || se || s || sw || w || nw)

    directions.each do |dir|
      case dir
      when Direction::North
        return {x, y - 1} if !(n || nw || ne)
      when Direction::South
        return {x, y + 1} if !(s || sw || se)
      when Direction::West
        return {x - 1, y} if !(w || nw || sw)
      when Direction::East
        return {x + 1, y} if !(e || ne || se)
      end
    end
  end

  def self.proposed_moves(directions)
    new_locations = Hash({Int32, Int32}, Array(Elf)).new do |hash, key|
      hash[key] = [] of Elf
    end

    @@map.each do |_, elf|
      proposal = elf.propose_move(directions)

      if proposal
        new_locations[proposal] << elf
      end
    end

    new_locations
  end

  def self.bounding_rectangle
    min_x, max_x = self.all.minmax_of { |elf| elf.location[0] }
    min_y, max_y = self.all.minmax_of { |elf| elf.location[1] }

    {min_x, max_x, min_y, max_y}
  end
end

AOC.lines.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    if char == '#'
      Elf.new({x, y})
    end
  end
end

directions = Direction.values

AOC.part1 do
  10.times do
    proposed_moves = Elf.proposed_moves(directions)

    proposed_moves.each do |new_location, elves|
      if elves.size == 1
        elves[0].location = new_location
      end
    end

    directions.rotate!
  end

  min_x, max_x, min_y, max_y = Elf.bounding_rectangle

  area = (max_x - min_x + 1) * (max_y - min_y + 1)
  area - Elf.all.size
end

AOC.part2 do
  rounds = 10
  loop do
    moved = false
    proposed_moves = Elf.proposed_moves(directions)

    proposed_moves.each do |new_location, elves|
      if elves.size == 1
        elves[0].location = new_location
        moved = true
      end
    end

    rounds += 1
    directions.rotate!

    break unless moved
  end

  p! Elf.bounding_rectangle

  rounds
end
