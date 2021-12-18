input =
  IO.stream(:line)
  |> Enum.map(&String.trim/1)

[dot_input, instruction_input] =
  input
  |> Enum.chunk_by(&(&1 == ""))
  |> Enum.reject(&(&1 == [""]))

dots =
  for dot_str <- dot_input do
    [x, y] = dot_str |> String.split(",") |> Enum.map(&String.to_integer/1)
    {x, y}
  end

folds =
  for instruction <- instruction_input do
    [_, dir, line] = Regex.run(~r/fold along (.)=(\d+)/, instruction)

    {
      String.to_atom(dir),
      String.to_integer(line)
    }
  end

defmodule Day13 do
  def fold_dot({x, y}, {:x, line}) when x > line do
    {line - (x - line), y}
  end

  def fold_dot({x, y}, {:y, line}) when y > line do
    {x, line - (y - line)}
  end

  def fold_dot({x, y}, {_, _}) do
    {x, y}
  end

  def print_dots(dots) do
    {max_x, _} = Enum.max_by(dots, &elem(&1, 0))
    {_, max_y} = Enum.max_by(dots, &elem(&1, 1))

    cells =
      for y <- 0..max_y do
        for x <- 0..max_x do
          MapSet.member?(dots, {x, y})
        end
      end
      |> Enum.chunk_every(2)
      |> Enum.map(&Enum.zip/1)

    # Use block drawing characters to draw two rows of the output at a time.
    # This is a bit more readable on a terminal, since it's not stretched
    # vertically so much.
    for row <- cells do
      for cell <- row do
        char =
          case cell do
            {true, true} -> "█"
            {true, false} -> "▀"
            {false, true} -> "▄"
            {false, false} -> " "
          end

        IO.write(char)
      end

      IO.puts("")
    end
  end
end

first_fold = hd(folds)

# Part 1
dots
|> Enum.map(&Day13.fold_dot(&1, first_fold))
|> Enum.uniq()
|> length()
|> IO.inspect()

# Part 2
final_dots =
  folds
  |> Enum.reduce(dots, fn
    fold, dots -> Enum.map(dots, &Day13.fold_dot(&1, fold))
  end)
  |> Enum.into(MapSet.new())

Day13.print_dots(final_dots)
