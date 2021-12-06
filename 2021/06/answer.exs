input =
  File.read!("input.txt")
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

fish_count =
  Enum.reduce(input, %{}, fn fish, acc ->
    Map.update(acc, fish, 1, &(&1 + 1))
  end)

sum_keys = fn _k, v1, v2 -> v1 + v2 end

next_day = fn fish_count ->
  Enum.reduce(fish_count, %{}, fn fish_pop, new_count ->
    case fish_pop do
      {0, count} -> Map.merge(new_count, %{6 => count, 8 => count}, sum_keys)
      {day, count} -> Map.merge(new_count, %{(day - 1) => count}, sum_keys)
    end
  end)
end

simulate_fish = fn days, start_fish_count ->
  Enum.reduce(1..days, start_fish_count, fn _day, acc ->
    next_day.(acc)
  end)
end

# Part 1
simulate_fish.(80, fish_count)
|> Map.values()
|> Enum.sum()
|> IO.inspect()

# Part 2
simulate_fish.(256, fish_count)
|> Map.values()
|> Enum.sum()
|> IO.inspect()
