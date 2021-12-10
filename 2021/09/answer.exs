input =
  File.stream!("input.txt")
  |> Stream.with_index()
  |> Enum.map(fn {line, row_num} ->
    line
    |> String.trim()
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map(fn {char, col_num} ->
      {{row_num, col_num}, String.to_integer(char)}
    end)
  end)
  |> List.flatten()
  |> Enum.into(%{})

defmodule Answer do
  def adjacent_points({x, y}, map) do
    for {x_off, y_off} <- [{-1, 0}, {1, 0}, {0, -1}, {0, 1}],
        neighbor_point = {x + x_off, y + y_off},
        Map.has_key?(map, neighbor_point) do
      {neighbor_point, Map.fetch!(map, neighbor_point)}
    end
  end

  def low_point?({point, height}, map) do
    adjacent_points(point, map)
    |> Enum.all?(fn {_, neighbor_height} ->
      neighbor_height > height
    end)
  end

  def reduce_to_basin([], basin_set, _map) do
    # No more points to consider, return the basin set
    basin_set
  end

  def reduce_to_basin([{_point, 9} | tail], basin_set, map) do
    # Height of 9 is not part of the basin
    reduce_to_basin(tail, basin_set, map)
  end

  def reduce_to_basin([{point, _height} | tail], basin_set, map) do
    if MapSet.member?(basin_set, point) do
      # Point is already part of the basin
      reduce_to_basin(tail, basin_set, map)
    else
      # Add point to the basin, and consider its neighbors
      new_points = adjacent_points(point, map)

      reduce_to_basin(
        new_points ++ tail,
        MapSet.put(basin_set, point),
        map
      )
    end
  end

  def largest_basins(basins, count) do
    basins
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(count)
  end
end

# Part 1
low_points = input |> Enum.filter(&Answer.low_point?(&1, input))

low_points
|> Enum.map(fn {_, height} -> height + 1 end)
|> Enum.sum()
|> IO.inspect()

# Part 2
low_points
|> Enum.map(&Answer.reduce_to_basin([&1], MapSet.new(), input))
|> Answer.largest_basins(3)
|> Enum.product()
|> IO.inspect()
