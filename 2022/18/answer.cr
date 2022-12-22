require "../aoc"

AOC.day!(18)

alias Droplet = {Int32, Int32, Int32}

droplets = Set(Droplet).new

AOC.each_line do |line|
  coords = line.split(",").map(&.to_i)

  droplets << Droplet.from(coords)
end

AOC.part1 do
  neighbor_offsets = [
    {-1, 0, 0},
    {1, 0, 0},
    {0, -1, 0},
    {0, 1, 0},
    {0, 0, -1},
    {0, 0, 1},
  ]

  droplets.map do |x, y, z|
    neighbor_offsets.count do |x_off, y_off, z_off|
      !droplets.includes?({x + x_off, y + y_off, z + z_off})
    end
  end.sum
end
