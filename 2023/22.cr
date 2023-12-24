require "./aoc"

AOC.day!(22)

class Brick
  @@by_id = {} of Int32 => Brick

  property id : Int32
  def_hash @id

  property x : Range(Int32, Int32)
  property y : Range(Int32, Int32)
  property z : Range(Int32, Int32)

  property above = Set(Brick).new
  property below = Set(Brick).new

  def self.[](id)
    @@by_id[id]
  end

  def initialize(@id, line)
    line.match! /(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/

    @x = $~[1].to_i..$~[4].to_i
    @y = $~[2].to_i..$~[5].to_i
    @z = $~[3].to_i..$~[6].to_i

    @@by_id[@id] = self
  end

  def can_disintegrate_safely?
    @above.empty? || @above.all? { |above| above.below.size > 1 }
  end

  def supporting_bricks
    return 0 if can_disintegrate_safely?

    gone_bricks = Set{self}
    queue = Deque.new(self.above.to_a)

    until queue.empty?
      brick = queue.shift

      if brick.below.subset_of?(gone_bricks)
        gone_bricks << brick
        queue.concat(brick.above)
      end
    end

    gone_bricks.size - 1
  end
end

bricks = AOC.lines.map_with_index do |line, i|
  Brick.new(i, line)
end

bricks.sort_by!(&.z.begin)

x_max = bricks.max_of(&.x.end)
y_max = bricks.max_of(&.y.end)
z_max = bricks.max_of(&.z.end)

grid = Array.new(size: x_max + 1) do
  Array.new(size: y_max + 1) do
    Array(Int32?).new(size: z_max + 1) do
      nil
    end
  end
end

bricks.each do |brick|
  settle_brick(brick, grid)
end

def settle_brick(brick, grid)
  xs = brick.x
  ys = brick.y
  z_bottom = brick.z.begin

  underneath = [] of Int32

  while z_bottom > 0
    xs.each do |x|
      ys.each do |y|
        if (id_below = grid[x][y][z_bottom - 1])
          underneath << id_below
        end
      end
    end

    if underneath.empty?
      z_bottom -= 1
    else
      break
    end
  end

  new_z = z_bottom...(z_bottom + brick.z.size)
  brick.z = new_z

  underneath = underneath.uniq.map { |id| Brick[id] }
  brick.below.concat(underneath)
  underneath.each do |under_brick|
    under_brick.above << brick
  end

  xs.each do |x|
    ys.each do |y|
      new_z.each do |z|
        grid[x][y][z] = brick.id
      end
    end
  end
end

AOC.part1 do
  bricks.count(&.can_disintegrate_safely?)
end

AOC.part2 do
  bricks.sum(&.supporting_bricks)
end
