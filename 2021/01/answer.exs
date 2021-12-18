input =
  for line <- IO.stream(:line) do
    line |> String.trim() |> String.to_integer()
  end

# Part 1
decreased? = fn [a, b] -> a < b end

input
|> Enum.chunk_every(2, 1, :discard)
|> Enum.filter(decreased?)
|> Enum.count()
|> IO.puts()

# Part 2
windows =
  input
  |> Enum.chunk_every(3, 1, :discard)
  |> Enum.map(&Enum.sum/1)

windows
|> Enum.chunk_every(2, 1, :discard)
|> Enum.filter(decreased?)
|> Enum.count()
|> IO.puts()
