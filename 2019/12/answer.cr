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

1000.times do
  moons.each_combination(2) do |(moon1, moon2)|
    moon1.gravitate_towards(moon2)
    moon2.gravitate_towards(moon1)
  end
  moons.each &.update
end

puts moons.sum &.total_energy
