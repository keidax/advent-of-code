enum Direction
  Up
  Down
  Left
  Right
end

struct Pos
  property x, y, distance

  def initialize(@x : Int16, @y : Int16, @distance : UInt32)
  end

  # Used for intersection, to ignore distance
  def_equals_and_hash @x, @y

  def trace_wire(coord : WireCoord) : Array(Pos)
    (1..coord[:distance]).map_with_index do |off, i|
      i += 1 # Index is offset by 1...
      case coord[:dir]
      when Direction::Right
        Pos.new(x + off, y, distance: distance + i)
      when Direction::Left
        Pos.new(x - off, y, distance: distance + i)
      when Direction::Up
        Pos.new(x, y + off, distance: distance + i)
      when Direction::Down
        Pos.new(x, y - off, distance: distance + i)
      else
        raise "oops"
      end
    end
  end
end

alias WireCoord = { dir: Direction, distance: Int32 }
alias WirePath = Array(WireCoord)

def make_path(line : String) : WirePath
  line.split(',').map do |coord|
    dir, dist = coord[0], coord[1..]

    direction : Direction = case dir
    when 'R' then Direction::Right
    when 'L' then Direction::Left
    when 'U' then Direction::Up
    when 'D' then Direction::Down
    else raise "unknown direction #{dir}"
    end

    { dir: direction, distance: dist.to_i }
  end
end

alias Grid = Set(Pos)

def fill_grid(path : WirePath) : Grid
  grid = Grid.new(150000)
  pos = Pos.new(0, 0, 0)

  path.each do |coord|
    added_wire = pos.trace_wire(coord)
    # Update pos
    pos = added_wire.last
    grid.concat(added_wire)
  end

  grid
end

paths = [] of WirePath

File.each_line("input.txt") do |line|
  paths << make_path(line)
end

puts paths.map &.size

grids = paths.map { |path| fill_grid(path) }
puts grids.map &.size

common = grids.reduce { |acc, g| acc & g }
puts common.size

intersections : Array(Array(Pos)) = common.map { |c| grids.compact_map { |g| g.find &.==(c) } }

puts intersections.map { |(a, b)| a.distance + b.distance }.min
