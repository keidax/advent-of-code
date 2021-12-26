defmodule Day22 do
  def parse_cuboid(line) do
    range = "([-\\d]+)..([-\\d]+)"
    [_ | nums] = Regex.run(~r/x=#{range},y=#{range},z=#{range}/, line)

    [x1, x2, y1, y2, z1, z2] = nums |> Enum.map(&String.to_integer/1)

    {x1..x2, y1..y2, z1..z2}
  end

  # Return true if 2 cuboids overlap
  def overlap?({x1, y1, z1}, {x2, y2, z2}) do
    !(Range.disjoint?(x1, x2) ||
        Range.disjoint?(y1, y2) ||
        Range.disjoint?(z1, z2))
  end

  # Given 2 cuboids, return a list of "faces" they intersect on on each axis.
  def intersections({x1, y1, z1}, {x2, y2, z2}) do
    [
      x: intersections(x1, x2),
      y: intersections(y1, y2),
      z: intersections(z1, z2)
    ]
  end

  # Disjoint ranges
  def intersections(a1..a2, b1..b2)
      when a1 > b2
      when b1 > a2 do
    []
  end

  # b within a
  def intersections(a1..a2, b1..b2) when a1 <= b1 and b2 <= a2 do
    [b1 - 0.5, b2 + 0.5]
  end

  # a within b
  def intersections(a1..a2, b1..b2) when b1 <= a1 and a2 <= b2 do
    [a1 - 0.5, a2 + 0.5]
  end

  # a less than b
  def intersections(a1..a2, b1..b2) when a1 < b1 and a2 < b2 do
    [b1 - 0.5, a2 + 0.5]
  end

  # b less than a
  def intersections(a1..a2, b1..b2) when b1 < a1 and b2 < a2 do
    [a1 - 0.5, b2 + 0.5]
  end

  # Given 2 overlapping cuboids, return a list of cuboids representing the
  # union of both cuboids, with no overlaps.
  def split(c1, c2) when is_tuple(c1) and is_tuple(c2) do
    splits = intersections(c1, c2)

    pieces1 = split(c1, splits)
    pieces2 = split(c2, splits)

    Enum.uniq(pieces1 ++ pieces2)
  end

  def split({x, y, z}, x: xsplits, y: ysplits, z: zsplits) do
    for x <- split_1d(x, xsplits),
        y <- split_1d(y, ysplits),
        z <- split_1d(z, zsplits) do
      {x, y, z}
    end
  end

  # Split a range into one or more ranges based on a list of split values.
  # Assume the split values are in sorted order.
  def split_1d(range, splits)

  def split_1d(r, []) do
    [r]
  end

  def split_1d(a..b, [split | rest]) when a < split and split < b do
    lower = a..floor(split)
    upper = ceil(split)..b

    [lower | split_1d(upper, rest)]
  end

  def split_1d(r, [_outside_split | rest]) do
    split_1d(r, rest)
  end

  # Given a list of cuboids, combine adjacent cuboids.
  def simplify(cuboids)

  def simplify([]), do: []

  def simplify([cube1 | rest]) do
    [c1_simple | rest] = simplify(cube1, rest)
    [c1_simple | simplify(rest)]
  end

  def simplify(cube1, []), do: [cube1]

  def simplify({x1..x2, y, z}, [{x3..x4, y, z} | rest]) when x2 + 1 == x3,
    do: simplify({x1..x4, y, z}, rest)

  def simplify({x1..x2, y, z}, [{x3..x4, y, z} | rest]) when x4 + 1 == x1,
    do: simplify({x3..x2, y, z}, rest)

  def simplify({x, y1..y2, z}, [{x, y3..y4, z} | rest]) when y2 + 1 == y3,
    do: simplify({x, y1..y4, z}, rest)

  def simplify({x, y1..y2, z}, [{x, y3..y4, z} | rest]) when y4 + 1 == y1,
    do: simplify({x, y3..y2, z}, rest)

  def simplify({x, y, z1..z2}, [{x, y, z3..z4} | rest]) when z2 + 1 == z3,
    do: simplify({x, y, z1..z4}, rest)

  def simplify({x, y, z1..z2}, [{x, y, z3..z4} | rest]) when z4 + 1 == z1,
    do: simplify({x, y, z3..z2}, rest)

  def simplify(cube1, [cube2 | rest]) do
    [cube2 | simplify(cube1, rest)]
  end

  def reduce({:on, c}, cuboid_set) do
    merge(c, cuboid_set)
    |> simplify
  end

  def reduce({:off, c}, cuboid_set) do
    merge(c, cuboid_set)
    |> Enum.reject(&overlap?(c, &1))
  end

  # Merge a cuboid into a list of cuboids. Assume that the input list has no overlaps.
  def merge(cuboid, cuboids)

  def merge(area, []) when is_tuple(area) do
    [area]
  end

  def merge(area1, [area2 | rest]) when is_tuple(area1) do
    if overlap?(area1, area2) do
      pieces = split(area1, area2)

      merge(pieces, rest)
    else
      [area2 | merge(area1, rest)]
    end
  end

  def merge([], set) do
    set
  end

  def merge([area | rest], set) do
    merge(rest, merge(area, set))
  end

  def size({x, y, z}) do
    Range.size(x) * Range.size(y) * Range.size(z)
  end

  def outside_bounds?({x1..x2, y1..y2, z1..z2}, a..b)
      when a <= x1 and x1 <= x2 and x2 <= b and
             a <= y1 and y2 <= b and
             a <= z1 and z2 <= b do
    false
  end

  def outside_bounds?(_area, _bounds), do: true

  def octants do
    for x <- [-1, 1], y <- [-1, 1], z <- [-1, 1] do
      {x, y, z}
    end
  end

  def filter_for_octant({command, {x, y, z}}, {x_sign, y_sign, z_sign}) do
    x = filter_on_axis(x, x_sign)
    y = filter_on_axis(y, y_sign)
    z = filter_on_axis(z, z_sign)

    cond do
      x == nil -> nil
      y == nil -> nil
      z == nil -> nil
      true -> {command, {x, y, z}}
    end
  end

  def filter_on_axis(range, sign)

  def filter_on_axis(a..b, 1) when 0 <= a, do: a..b
  def filter_on_axis(a..b, 1) when a < 0 and 0 <= b, do: 0..b
  def filter_on_axis(_a..b, 1) when b < 0, do: nil

  def filter_on_axis(a..b, -1) when b < 0, do: a..b
  def filter_on_axis(a..b, -1) when a < 0 and 0 <= b, do: a..-1
  def filter_on_axis(a.._b, -1) when 0 <= a, do: nil

  def count_cubes(instructions) do
    instructions
    |> Enum.reduce([], &reduce/2)
    |> Enum.map(&size/1)
    |> Enum.sum()
  end
end

instructions =
  IO.stream(:line)
  |> Enum.map(fn
    <<"on ", rest::binary>> -> {:on, Day22.parse_cuboid(rest)}
    <<"off ", rest::binary>> -> {:off, Day22.parse_cuboid(rest)}
  end)

# Part 1
inner_instructions =
  instructions
  |> Enum.reject(fn {_, area} -> Day22.outside_bounds?(area, -50..50) end)

inner_instructions
|> Day22.count_cubes()
|> IO.inspect()

# Part 2
Day22.octants()
|> Enum.map(fn oct ->
  instructions
  |> Enum.map(&Day22.filter_for_octant(&1, oct))
  |> Enum.reject(&is_nil/1)
end)
|> Enum.map(fn split_instructions ->
  Task.async(fn -> Day22.count_cubes(split_instructions) end)
end)
|> Enum.map(&Task.await/1)
|> Enum.sum()
|> IO.inspect()
