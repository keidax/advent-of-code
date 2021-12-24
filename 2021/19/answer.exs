# Represent a 3-dimensional direction & orienation as a list of 3 tuples. Each
# tuple consists of an atom (:x, :y, or :z) representing the axis, and a sign
# that is positive or negative.
defmodule Direction do
  # Define orientation of 6 primary directions
  def primary_directions do
    [
      # east
      [x: 1, y: 1, z: 1],
      # north
      [y: 1, x: -1, z: 1],
      # west
      [x: -1, y: -1, z: 1],
      # south
      [y: -1, x: 1, z: 1],
      # up
      [z: 1, y: 1, x: -1],
      # down
      [z: -1, y: 1, x: 1]
    ]
  end

  # Given an orientation, return the 4 possible ways to spin that orientation around its first axis
  def rotate_on_axis([{a, a_sign}, {b, b_sign}, {c, c_sign}]) do
    [
      [{a, a_sign}, {b, b_sign}, {c, c_sign}],
      [{a, a_sign}, {c, c_sign}, {b, -b_sign}],
      [{a, a_sign}, {b, -b_sign}, {c, -c_sign}],
      [{a, a_sign}, {c, -c_sign}, {b, b_sign}]
    ]
  end

  def all_rotations do
    for axis <- primary_directions(), dir <- rotate_on_axis(axis) do
      dir
    end
  end

  def elem(point, :x), do: Kernel.elem(point, 0)
  def elem(point, :y), do: Kernel.elem(point, 1)
  def elem(point, :z), do: Kernel.elem(point, 2)
end

defmodule Day19 do
  def parse_scanner([header | numbers], acc) do
    [_, num] = Regex.run(~r/--- scanner (\d+) ---/, header)
    num = String.to_integer(num)

    beacons =
      numbers
      |> Enum.map(&parse_beacon/1)
      |> split_into_octants

    Map.put(acc, num, beacons)
  end

  def parse_beacon(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def split_into_octants(beacons) do
    beacons
    |> Enum.group_by(&octant/1)
    |> Map.values()
  end

  def octant({x, y, z}) do
    {
      x >= 0,
      y >= 0,
      z >= 0
    }
  end

  def octant_diff({x1, y1, z1}, {x2, y2, z2}) do
    [
      x1 - x2,
      y1 - y2,
      z1 - z2
    ]
    |> Enum.map(&abs/1)
    |> Enum.sort()
    |> List.to_tuple()
  end

  def octant_diffs(octant) do
    for a <- octant, b <- octant, a != b do
      octant_diff(a, b)
    end
    |> Enum.uniq()
  end

  @rotations Direction.all_rotations()

  def all_rotations_for_octants(octants) do
    @rotations
    |> Stream.map(fn
      rot ->
        for points <- octants do
          points |> Enum.map(&rotate_point(&1, rot))
        end
    end)
  end

  def rotate_point(point, [{x_dir, x_sign}, {y_dir, y_sign}, {z_dir, z_sign}]) do
    {
      Direction.elem(point, x_dir) * x_sign,
      Direction.elem(point, y_dir) * y_sign,
      Direction.elem(point, z_dir) * z_sign
    }
  end

  def {x1, y1, z1} --- {x2, y2, z2} do
    {x1 - x2, y1 - y2, z1 - z2}
  end

  def {x1, y1, z1} +++ {x2, y2, z2} do
    {x1 + x2, y1 + y2, z1 + z2}
  end

  def distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  # This comparison occurs after rotation. If the scanners have at least 12
  # overlapping beacons, returns the offset value, and the beacons of scanner2
  # translated relative to scanner1. Otherwise, returns nil.
  def compare_by_octants(scanner1, scanner2) do
    possible_offsets =
      for oct1 <- scanner1, oct2 <- scanner2 do
        compare_octant(oct1, oct2)
      end
      |> Stream.reject(&is_nil/1)

    points1 = List.flatten(scanner1)
    points2 = List.flatten(scanner2)

    target =
      possible_offsets
      |> Stream.map(fn
        offset -> {offset, Enum.map(points2, &(&1 +++ offset))}
      end)
      |> Enum.find(fn
        {_offset, offset_points2} -> equal_point_count(points1, offset_points2) >= 12
      end)

    case target do
      nil ->
        nil

      {offset, _points} ->
        new_octants =
          for oct <- scanner2 do
            for beacon <- oct do
              beacon +++ offset
            end
          end

        {offset, new_octants}
    end
  end

  # Count how many elements are in both lists. Does not account for duplicates.
  def equal_point_count(list1, list2) do
    for a <- list1, reduce: 0 do
      acc ->
        acc +
          if a in list2 do
            1
          else
            0
          end
    end
  end

  def diff_map_for_octant(octant) do
    for a <- octant, b <- octant, a != b, into: %{} do
      {a --- b, a}
    end
  end

  # If oct1 and oct2 both contain 2 points that are offset by an identical
  # amount, return the offset distance from oct1 to oct2.
  # Otherwise, return nil.
  def compare_octant(oct1, oct2) do
    diffs1 = diff_map_for_octant(oct1)

    diffs2 = diff_map_for_octant(oct2)

    same_diff =
      diffs1
      |> Map.keys()
      |> Enum.find(&Map.has_key?(diffs2, &1))

    if same_diff do
      a1 = diffs1[same_diff]
      a2 = diffs2[same_diff]

      a1 --- a2
    else
      nil
    end
  end

  def translate_adjacent(scanners, translated_map, adjacent_map, scanner_id, remaining) do
    {_, base_octs} = translated_map[scanner_id]
    adj_scanners = adjacent_map[scanner_id]

    translated_map =
      for adj_scanner <- adj_scanners,
          reduce: translated_map do
        acc ->
          translate_by_octants(scanners, acc, base_octs, adj_scanner)
      end

    remaining = remaining -- [scanner_id]

    adj_scanners
    |> Enum.reduce({remaining, translated_map}, fn
      next_scanner, {list, map} ->
        if is_map_key(map, next_scanner) and next_scanner in list do
          translate_adjacent(scanners, map, adjacent_map, next_scanner, list)
        else
          {list, map}
        end
    end)
  end

  def translate_by_octants(_scanners, translated_map, _base_octs, scanner_id)
      when is_map_key(translated_map, scanner_id) do
    translated_map
  end

  def translate_by_octants(scanners, translated_map, base_octs, scanner_id) do
    adj_octs = scanners[scanner_id]
    rotated_octs = Day19.all_rotations_for_octants(adj_octs)

    translated =
      rotated_octs
      |> Stream.map(&Day19.compare_by_octants(base_octs, &1))
      |> Enum.find(&(&1 != nil))

    case translated do
      nil ->
        translated_map

      {offset, new_octs} when is_list(new_octs) ->
        Map.put(translated_map, scanner_id, {offset, new_octs})
    end
  end
end

scanners =
  IO.stream(:line)
  |> Enum.map(&String.trim/1)
  |> Enum.chunk_by(&(&1 == ""))
  |> Enum.reject(&(&1 == [""]))
  |> Enum.reduce(%{}, &Day19.parse_scanner/2)

max_scanner_id =
  scanners
  |> Map.keys()
  |> Enum.max()

scanner_diffs =
  Map.map(scanners, fn
    {_num, octants} -> octants |> Enum.map(&Day19.octant_diffs/1)
  end)

likely_adjacent_scanners =
  for scanner1 <- 0..max_scanner_id,
      scanner2 <- scanner1..max_scanner_id,
      scanner1 != scanner2,
      reduce: %{} do
    acc ->
      diffs1 =
        scanner_diffs[scanner1]
        |> List.flatten()

      diffs2 =
        scanner_diffs[scanner2]
        |> List.flatten()

      disjoint? = diffs1 -- diffs2 == diffs1

      if disjoint? do
        acc
      else
        acc
        |> Map.update(scanner1, [scanner2], &[scanner2 | &1])
        |> Map.update(scanner2, [scanner1], &[scanner1 | &1])
      end
  end

translated_scanners = %{0 => {{0, 0, 0}, scanners[0]}}
all_scanners = Map.keys(scanners)

translated_map =
  Day19.translate_adjacent(
    scanners,
    translated_scanners,
    likely_adjacent_scanners,
    0,
    all_scanners
  )
  |> elem(1)

all_beacons =
  translated_map
  |> Map.values()
  |> Enum.map(&elem(&1, 1))
  |> List.flatten()
  |> Enum.uniq()

# Part 1
all_beacons
|> length()
|> IO.inspect()

# Part 2
all_scanners =
  translated_map
  |> Map.values()
  |> Enum.map(&elem(&1, 0))
  |> List.flatten()
  |> Enum.uniq()

for a <- all_scanners, b <- all_scanners do
  Day19.distance(a, b)
end
|> Enum.max()
|> IO.inspect()
