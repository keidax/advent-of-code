input = File.stream!("input.txt")
|> Enum.map(&String.trim/1)

# Part 1
to_i = &String.to_integer/1

update_direction = fn command, {x, y} ->
  case command do
    "forward " <> move -> {x + to_i.(move), y}
    "down " <> move -> {x, y + to_i.(move)}
    "up " <> move -> {x, y - to_i.(move)}
  end
end

input
|> Enum.reduce({0, 0}, update_direction)
|> then(fn {x, y} -> x * y end)
|> IO.inspect

# Part 2
update_direction_and_aim = fn command, {x, y, aim} ->
  case command do
    "forward " <> move -> {x + to_i.(move), y + aim * to_i.(move), aim}
    "down " <> move -> {x, y, aim + to_i.(move)}
    "up " <> move -> {x, y, aim - to_i.(move)}
  end
end

input
|> Enum.reduce({0, 0, 0}, update_direction_and_aim)
|> then(fn {x, y, _} -> x * y end)
|> IO.inspect
