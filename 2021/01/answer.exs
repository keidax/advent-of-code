input = File.stream!("input.txt")
|> Enum.map(&(&1 |> String.trim |> String.to_integer))

# Part 1
decreased? = fn [a, b] -> a < b end

input
|> Enum.chunk_every(2, 1, :discard)
|> Enum.filter(decreased?)
|> Enum.count
|> IO.puts

# Part 2
windows = input
|> Enum.chunk_every(3, 1, :discard)
|> Enum.map(&Enum.sum/1)

windows
|> Enum.chunk_every(2, 1, :discard)
|> Enum.filter(decreased?)
|> Enum.count
|> IO.puts
