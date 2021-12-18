input =
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

defmodule Answer do
  def coalesce_points(points) do
    for point <- points, reduce: %{} do
      acc -> Map.update(acc, point, 1, &(&1 + 1))
    end
  end

  def add_energy(octopi, n) when is_integer(n) do
    Map.map(octopi, fn
      {_pos, :flashed} -> :flashed
      {_pos, energy} -> energy + n
    end)
  end

  def add_energy(octopi, points) when is_list(points) do
    new_energy = coalesce_points(points)

    # If an octopus has already flashed, keep that state.
    # Otherwise add the energy.
    Map.merge(octopi, new_energy, fn
      _point, :flashed, _v2 -> :flashed
      _point, v1, v2 -> v1 + v2
    end)
  end

  def adjacent_points({x, y}, octopi) do
    for x_off <- -1..1,
        y_off <- -1..1,
        !(x_off == 0 && y_off == 0),
        neighbor = {x + x_off, y + y_off},
        Map.has_key?(octopi, neighbor),
        do: neighbor
  end

  def get_points_ready_to_flash(octopi) do
    Enum.reduce(octopi, [], fn
      {_point, :flashed}, acc -> acc
      {point, energy}, acc when energy > 9 -> [point | acc]
      {_point, _energy}, acc -> acc
    end)
  end

  def get_octopi_after_flashes(octopi) do
    Map.map(octopi, fn
      {_point, :flashed} -> :flashed
      {_point, energy} when energy > 9 -> :flashed
      {_point, energy} -> energy
    end)
  end

  def simulate_flashes(octopi) do
    flash_points = get_points_ready_to_flash(octopi)

    adjacent_flash_points =
      flash_points
      |> Enum.flat_map(&adjacent_points(&1, octopi))

    octopi_after_flashes =
      octopi
      |> get_octopi_after_flashes
      |> add_energy(adjacent_flash_points)

    more_ready_to_flash? =
      octopi_after_flashes
      |> Enum.any?(fn
        {_point, :flashed} -> false
        {_point, energy} -> energy > 9
      end)

    if more_ready_to_flash? do
      simulate_flashes(octopi_after_flashes)
    else
      octopi_after_flashes
    end
  end

  def reset_after_flashes(octopi) do
    Map.map(octopi, fn
      {_point, :flashed} -> 0
      {_point, energy} -> energy
    end)
  end

  # Returns updated octopi and the number of flashes
  def run_step(octopi) do
    octopi = add_energy(octopi, 1)

    octopi_after_flashes = simulate_flashes(octopi)

    flash_count =
      octopi_after_flashes
      |> Map.values()
      |> Enum.count(&(&1 == :flashed))

    new_octopi = reset_after_flashes(octopi_after_flashes)

    {new_octopi, flash_count}
  end

  def step_until_synced(octopi, rounds) do
    {octopi, flash_count} = run_step(octopi)

    rounds = rounds + 1

    if flash_count == map_size(octopi) do
      rounds
    else
      step_until_synced(octopi, rounds)
    end
  end
end

# Part 1
1..100
|> Enum.reduce({input, 0}, fn _, {octopi, acc} ->
  {new_octopi, flashes} = Answer.run_step(octopi)
  {new_octopi, acc + flashes}
end)
|> then(fn {_, flash_count} -> IO.inspect(flash_count) end)

# Part 2
IO.inspect(Answer.step_until_synced(input, 0))
