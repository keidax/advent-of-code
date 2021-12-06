get_coords = fn line ->
  [_ | coords] = Regex.run(~r/(\d+),(\d+) -> (\d+),(\d+)/, line)

  coords |> Enum.map(&String.to_integer/1) |> List.to_tuple()
end

input =
  File.stream!("input.txt")
  |> Enum.map(get_coords)

coords_in_line = fn
  {x, y1, x, y2} ->
    for y <- y1..y2, do: {x, y}

  {x1, y, x2, y} ->
    for x <- x1..x2, do: {x, y}

  {x1, y1, x2, y2} ->
    Enum.zip(x1..x2, y1..y2)
end

build_vent_map = fn lines ->
  Enum.reduce(lines, %{}, fn coords, acc ->
    for {x, y} <- coords_in_line.(coords), into: acc do
      vent_count = Map.get(acc, {x, y}, 0)
      {{x, y}, vent_count + 1}
    end
  end)
end

vertical_or_horizontal? = fn coords ->
  case coords do
    {x, _, x, _} -> true
    {_, y, _, y} -> true
    _ -> false
  end
end

# Part 1
non_diagonals = input |> Enum.filter(vertical_or_horizontal?)

vent_map = build_vent_map.(non_diagonals)

vent_map
|> Map.values()
|> Enum.filter(&(&1 >= 2))
|> Enum.count()
|> IO.inspect()

# Part 2
full_vent_map = build_vent_map.(input)

full_vent_map
|> Map.values()
|> Enum.filter(&(&1 >= 2))
|> Enum.count()
|> IO.inspect()
