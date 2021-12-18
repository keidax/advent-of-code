risk_map =
  IO.stream(:line)
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

defmodule Day15 do
  @empty MapSet.new()

  def measure_risk(_risk_map, cost_map, positions) when positions == @empty do
    cost_map
  end

  # This is basically a naive recursive implementation of Dijkstra's
  # algorithm. It's quite inefficient without using a heap.
  def measure_risk(risk_map, cost_map, positions) do
    next_pos = positions |> Enum.min_by(&Map.get(cost_map, &1))

    positions = MapSet.delete(positions, next_pos)

    {next_cost_map, next_position_set} = measure_risk_pos(risk_map, cost_map, next_pos, positions)

    measure_risk(risk_map, next_cost_map, next_position_set)
  end

  def measure_risk_pos(risk_map, cost_map, pos, next_positions) do
    cost = Map.fetch!(cost_map, pos)

    {x, y} = pos

    neighbors =
      for neighbor when is_map_key(risk_map, neighbor) <- [
            {x - 1, y},
            {x + 1, y},
            {x, y - 1},
            {x, y + 1}
          ] do
        neighbor
      end

    for neighbor <- neighbors,
        neighbor_risk = Map.fetch!(risk_map, neighbor),
        reduce: {cost_map, next_positions} do
      {cost_map, positions} ->
        positions =
          if Map.has_key?(cost_map, neighbor) do
            positions
          else
            MapSet.put(positions, neighbor)
          end

        neighbor_cost = cost + neighbor_risk
        cost_map = Map.update(cost_map, neighbor, neighbor_cost, &min(neighbor_cost, &1))

        {cost_map, positions}
    end
  end

  def full_path_cost(cost_map) do
    max_row =
      cost_map
      |> Enum.map(fn {{row, _}, _} -> row end)
      |> Enum.max()

    max_col =
      cost_map
      |> Enum.map(fn {{_, col}, _} -> col end)
      |> Enum.max()

    cost_map
    |> Map.get({max_row, max_col})
  end

  def tiled_risk_map(risk_map) do
    row_count =
      risk_map
      |> Enum.map(fn {{row, _}, _} -> row end)
      |> Enum.max()
      |> then(&(&1 + 1))

    col_count =
      risk_map
      |> Enum.map(fn {{_, col}, _} -> col end)
      |> Enum.max()
      |> then(&(&1 + 1))

    for {{row, col}, risk} <- risk_map, row_mult <- 0..4, col_mult <- 0..4, into: %{} do
      new_row = row + row_count * row_mult
      new_col = col + col_count * col_mult

      new_risk = rem(risk - 1 + row_mult + col_mult, 9) + 1

      {{new_row, new_col}, new_risk}
    end
  end
end

# Part 1
cost_map =
  Day15.measure_risk(
    risk_map,
    %{{0, 0} => 0},
    MapSet.new([{0, 0}])
  )

cost_map
|> Day15.full_path_cost()
|> IO.inspect()

# Part 2
full_risk_map = Day15.tiled_risk_map(risk_map)

full_cost_map =
  Day15.measure_risk(
    full_risk_map,
    %{{0, 0} => 0},
    MapSet.new([{0, 0}])
  )

full_cost_map
|> Day15.full_path_cost()
|> IO.inspect()
