require "./aoc"

require "big"

AOC.day!(24)

class Hailstone
  property x : Int128, y : Int128, z : Int128
  property dx : Int128, dy : Int128, dz : Int128

  def initialize(line)
    line = line.gsub(/[,@]/, "")

    @x, @y, @z, @dx, @dy, @dz = line.split(/\s+/).map(&.to_i128)
  end

  def slope_2d
    BigRational.new(dy, dx)
  end

  def offset_2d
    y - (x * slope_2d)
  end

  def intersecting_point(other)
    if dx.zero?
      joint_x = BigRational.new(x)
      joint_y = other.slope_2d * joint_x + other.offset_2d
    elsif other.dx.zero?
      joint_x = BigRational.new(other.x)
      joint_y = slope_2d * joint_x + offset_2d
    else
      s1 = slope_2d
      s2 = other.slope_2d

      c1 = offset_2d
      c2 = other.offset_2d

      joint_x = (c2 - c1)/(s1 - s2)
      joint_y = s1 * joint_x + c1
    end

    {joint_x, joint_y}
  end

  def intersect_2d_path?(other, xrange, yrange) : {BigRational, BigRational}?
    if (other.dy * dx) == (other.dx * dy)
      # slopes are the same
      return nil
    end

    joint_x, joint_y = intersecting_point(other)

    unless xrange.includes?(joint_x.to_big_i)
      return nil
    end

    unless yrange.includes?(joint_y.to_big_i)
      return nil
    end

    if same_sign?(x - joint_x, dx) || same_sign?(other.x - joint_x, other.dx)
      # crossed in the past
      return nil
    end

    {joint_x, joint_y}
  end

  def same_sign?(a, b)
    (a < 0 && b < 0) || (a > 0) && (b > 0)
  end

  def shift_velocity(dx, dy, dz)
    @dx -= dx
    @dy -= dy
    @dz -= dz
    self
  end

  def flip_x_z
    @x, @z = @z, @x
    @dx, @dz = @dz, @dx
  end
end

hailstones = AOC.lines.map { |l| Hailstone.new(l) }

AOC.part1 do
  range = 200_000_000_000_000..400_000_000_000_000

  hailstones.each_combination(size: 2).count do |(a, b)|
    a.intersect_2d_path?(b, range, range)
  end
end

# Instead of searching for a limited range of velocities, we can check all 2-integer
# combinations in a widening spiral.
# Based on https://stackoverflow.com/a/14010215
class SpiralOut
  include Iterator({Int32, Int32})

  def initialize
    @x = @y = @side = 0
    @limit = 1
  end

  def next
    case @side
    when 0 # top
      @x += 1
      if @x == @limit
        @side += 1
      end
    when 1 # right
      @y -= 1
      if @y == -@limit
        @side += 1
      end
    when 2 # bottom
      @x -= 1
      if @x == -@limit
        @side += 1
      end
    when 3 # left
      @y += 1
      if @y == @limit
        @side = 0
        @limit += 1
      end
    end

    return {@x, @y}
  end
end

AOC.part2 do
  # The solution is based on this explaination:
  # https://www.reddit.com/r/adventofcode/comments/18pnycy/2023_day_24_solutions/keq7g67/

  x, y = find_x_y_origin(hailstones[0..10])

  hailstones.each(&.flip_x_z)

  z, other_y = find_x_y_origin(hailstones[0..10])

  if y != other_y
    raise "uh oh"
  end

  x + y + z
end

def find_x_y_origin(hailstones)
  found = false
  spiral = SpiralOut.new

  x = BigRational.new(0)
  y = BigRational.new(0)

  loop do
    dx, dy = spiral.next

    if (res = test_velocities(dx, dy, hailstones))
      x, y = res
      break
    end
  end

  {x, y}
end

def test_velocities(dx, dy, hailstones)
  target = nil

  hailstones.each_cons_pair do |a, b|
    a.shift_velocity(dx, dy, 0)
    b.shift_velocity(dx, dy, 0)

    possibility = a.intersect_2d_path?(b, (..), (..))

    same_line = if possibility
                  false
                elsif a.dx == 0 || b.dx == 0
                  # one of the lines is vertical, so slope_2d would raise an error
                  a.dx == 0 && b.dx == 0 && a.x == b.x
                else
                  a.slope_2d == b.slope_2d && a.offset_2d == b.offset_2d
                end

    a.shift_velocity(-dx, -dy, 0)
    b.shift_velocity(-dx, -dy, 0)

    if possibility.nil?
      if same_line
        next
      else
        return nil
      end
    end

    return if possibility[0].denominator != 1
    return if possibility[1].denominator != 1

    if target
      if possibility == target
        # good
      else
        return nil
      end
    else
      target = possibility
    end
  end

  target
end
