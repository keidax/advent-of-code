# Determined from inputs
MIN_X = -5000
MIN_Y = -14000
MAX_X = 9000
MAX_Y = 8000

# alias Grid = Bool[14000][22000]

enum Direction
  Up
  Down
  Left
  Right
end

alias Pos = UInt32

struct Pos
  def self.new(x : Int16, y : Int16) : self
    ((x.to_u32! << 16) | y.to_u16!).to_u32
  end

  def x : Int16
    (self >> 16).to_i16!
  end

  def y : Int16
    (self & 0xffff).to_i16!
  end

  def distance : Int16
    x.abs + y.abs
  end

  def trace_wire(coord : WireCoord) : Array(Pos)
    (1..coord[:distance]).map do |off|
      case coord[:dir]
      when Direction::Right
        # print 'R'
        Pos.new(x + off, y)
      when Direction::Left
        # print 'L'
        Pos.new(x - off, y)
      when Direction::Up
        # print 'U'
        Pos.new(x, y + off)
      when Direction::Down
        # print 'D'
        Pos.new(x, y - off)
      else
        print '0'
        0_u32
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

alias Grid = Set(UInt32)

def fill_grid(path : WirePath) : Grid
  grid = Grid.new(5000)
  pos = Pos.new(0, 0)

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

puts common.map(&.distance).min
