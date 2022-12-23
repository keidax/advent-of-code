require "../aoc"

AOC.day!(18)

alias Cube = {Int32, Int32, Int32}

cubes = Set(Cube).new

AOC.each_line do |line|
  coords = line.split(",").map(&.to_i)

  cubes << Cube.from(coords)
end

NEIGHBOR_OFFSETS = [
  {-1, 0, 0},
  {1, 0, 0},
  {0, -1, 0},
  {0, 1, 0},
  {0, 0, -1},
  {0, 0, 1},
]

def neighbors(cube : Cube)
  x, y, z = cube
  NEIGHBOR_OFFSETS.map { |x_off, y_off, z_off| {x + x_off, y + y_off, z + z_off} }
end

def count_exposed_sides(cubes)
  cubes.map do |cube|
    neighbors(cube).count do |neighbor|
      !cubes.includes?(neighbor)
    end
  end.sum
end

AOC.part1 do
  count_exposed_sides(cubes)
end

def fill_interior_pockets(cubes)
  x_min = y_min = z_min = Int32::MAX
  x_max = y_max = z_max = Int32::MIN

  cubes.each do |x, y, z|
    x_min = x if x < x_min
    y_min = y if y < y_min
    z_min = z if z < z_min

    x_max = x if x > x_max
    y_max = y if y > y_max
    z_max = z if z > z_max
  end

  outside = Set(Cube).new

  fill_pocket = ->(first_cube : Cube) do
    visited = Set(Cube).new
    unvisited = Set{first_cube}

    while unvisited.any?
      cube = unvisited.first
      unvisited.delete(cube)

      x, y, z = cube

      if outside.includes?(cube) ||
         x <= x_min || x >= x_max ||
         y <= y_min || y >= y_max ||
         z <= z_min || z >= z_max
        # this pocket is not contained
        outside << cube
        outside.concat(visited)
        outside.concat(unvisited)
        return
      end

      neighbors(cube).each do |neighbor|
        next if cubes.includes?(neighbor)
        next if visited.includes?(neighbor)
        unvisited << neighbor
      end

      visited << cube
    end

    # if we reach here, visited contains all cubes and the pocket is fully trapped
    cubes.concat(visited)
  end

  (x_min..x_max).each do |x|
    (y_min..y_max).each do |y|
      (z_min..z_max).each do |z|
        cube = {x, y, z}
        next if cubes.includes?(cube)
        next if outside.includes?(cube)

        fill_pocket.call(cube)
      end
    end
  end
end

AOC.part2 do
  fill_interior_pockets(cubes)
  count_exposed_sides(cubes)
end
