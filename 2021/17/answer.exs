line =
  IO.read(:line)
  |> String.trim()

[x1, x2, y1, y2] =
  Regex.run(~r/target area: x=([-\d]+)..([-\d]+), y=([-\d]+)..([-\d]+)/, line)
  |> Enum.take(-4)
  |> Enum.map(&String.to_integer/1)

target_x = x1..x2
target_y = y1..y2

defmodule Day17 do
  # Check if the given position and velocity will eventually reach the target
  # area, considering only the x direction.
  def hits_x?(range, x, vx)
  # In target area
  def hits_x?(min_x..max_x, x, _) when x in min_x..max_x, do: true
  # Overshot target
  def hits_x?(_..max_x, x, _) when x > max_x, do: false
  # Undershot target
  def hits_x?(_, _, 0), do: false

  def hits_x?(range, x, vx) do
    hits_x?(range, x + vx, vx - 1)
  end

  # Check if the given position and velocity will eventually reach the target
  # area, considering only the y direction.
  def hits_y?(range_y, y, vy)
  # In target area
  def hits_y?(min_y..max_y, y, _) when y in min_y..max_y, do: true
  # Below target
  def hits_y?(min_y.._, y, _) when y < min_y, do: true

  def hits_y?(range_y, y, vy) do
    hits_y?(range_y, y + vy, vy - 1)
  end

  # Check if the given position and velocity will eventually reach the target
  # area.
  def hits_target?(range_x, range_y, x, y, vx, vy)

  # In target area
  def hits_target?(min_x..max_x, min_y..max_y, x, y, _, _)
      when x in min_x..max_x and y in min_y..max_y,
      do: true

  # Overshot x
  def hits_target?(_..max_x, _, x, _, _, _)
      when x > max_x,
      do: false

  # Below target y
  def hits_target?(_, min_y.._, _, y, _, _)
      when y < min_y,
      do: false

  def hits_target?(range_x, range_y, x, y, vx, vy) do
    hits_target?(range_x, range_y, x + vx, y + vy, max(0, vx - 1), vy - 1)
  end

  def max_y(y) do
    # Sum of natural numbers
    div(y * (y + 1), 2)
  end
end

# Part 1

# To narrow down the search, first generate a list of all possible x velocities
# and y velocities that might work, only considering one direction at a time.
x_vels =
  0..max(x1, x2)
  |> Enum.filter(&Day17.hits_x?(target_x, 0, &1))

neg_y_vels =
  -1..min(y1, y2)
  |> Enum.filter(&Day17.hits_y?(target_y, 0, &1))

# A probe fired with a positive y velocity of v will eventually return to a
# position of zero with a velocity of -v. On the next step, it will have the
# same velocity as a probe fired from the origin with a velocity of -(v + 1).
pos_y_vels =
  neg_y_vels
  |> Enum.map(&(&1 * -1 - 1))

y_vels =
  (neg_y_vels ++ pos_y_vels)
  |> Enum.sort(:desc)

possible_vels =
  for vy <- y_vels, vx <- x_vels do
    {vx, vy}
  end

{_vx, highest_vy} =
  possible_vels
  |> Enum.find(fn
    {vx, vy} -> Day17.hits_target?(target_x, target_y, 0, 0, vx, vy)
  end)

highest_vy
|> Day17.max_y()
|> IO.inspect()

# Part 2
possible_vels
|> Enum.filter(fn
  {vx, vy} -> Day17.hits_target?(target_x, target_y, 0, 0, vx, vy)
end)
|> length
|> IO.inspect()
