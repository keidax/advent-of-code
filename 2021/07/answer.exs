input =
  IO.read(:line)
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

cost_at_position = fn crabs, pos, cost_fn ->
  crabs
  |> Enum.map(&cost_fn.(&1, pos))
  |> Enum.sum()
end

min_cost = fn crabs, cost_fn ->
  max_pos = Enum.max(crabs)

  0..max_pos
  |> Enum.map(&cost_at_position.(crabs, &1, cost_fn))
  |> Enum.min()
end

# Part 1
direct_fuel_cost = &abs(&1 - &2)

min_cost.(input, direct_fuel_cost)
|> IO.inspect()

# Part 2
increasing_fuel_cost = fn pos1, pos2 ->
  diff = abs(pos1 - pos2)

  # Sum of natural numbers
  div(diff * (diff + 1), 2)
end

min_cost.(input, increasing_fuel_cost)
|> IO.inspect()
