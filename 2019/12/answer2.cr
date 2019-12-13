class Point
  property pos : Int32, vel = 0

  def_hash pos, vel

  def initialize(@pos)
  end

  def gravitate_towards(other : Point)
    diff = other.pos <=> pos
    @vel += diff
  end

  def update
    @pos += @vel
  end
end

class Axis
  property points : Array(Point)

  def initialize(positions : Array(Int32))
    @points = positions.map &->Point.new(Int32)
  end

  def cycles : Int32
    prev = Set(UInt64).new
    i = 0

    loop do
      hash = points.hash
      if prev.includes? hash
        return i
      end
      prev << hash
      i += 1

      points.each_combination(2) do |(p1, p2)|
        p1.gravitate_towards(p2)
        p2.gravitate_towards(p1)
      end
      points.each &.update
    end
  end
end

class Position
  property x : Int32, y : Int32, z : Int32

  def_hash x, y, z

  def initialize(@x, @y, @z)
  end

  def difference(other : Position)
    Position.new(
      other.x <=> x,
      other.y <=> y,
      other.z <=> z,
    )
  end

  def add(other : Position)
    @x += other.x
    @y += other.y
    @z += other.z
  end

  def absolute
    x.abs + y.abs + z.abs
  end
end

alias Velocity = Position

class Moon
  property position
  property velocity = Velocity.new(0, 0, 0)

  def_hash position, velocity

  def initialize(x, y, z)
    @position = Position.new(x, y, z)
  end

  def gravitate_towards(other : Moon)
    diff = position.difference(other.position)
    velocity.add(diff)
  end

  def update
    position.add(velocity)
  end

  def total_energy
    position.absolute * velocity.absolute
  end
end

inputs = File.read_lines("input.txt")
moons = inputs.map do |line|
  coords = line.match(/<x=([-\d]+), y=([-\d]+), z=([-\d]+)>/).not_nil!.to_a.compact[1..4]
  tup = Tuple(Int32, Int32, Int32).from(coords.map(&.to_i))
  Moon.new *tup
end

axes = moons
  .map { |m| pos = m.position; [pos.x, pos.y, pos.z] }
  .transpose
  .map { |points| Axis.new(points) }

cycles = axes.map &.cycles
puts cycles

puts cycles.reduce(1_i64) { |l, i| l.lcm(i.to_i64) }
