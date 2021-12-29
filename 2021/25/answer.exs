defmodule Day25 do
  # Create chunks of 3, with the first and last elements wrapped around. E.g.
  #   wrapped_chunks([0, 1, 2, 3, 4])
  # produces
  #  [[4,0,1], [0,1,2], [1,2,3], [2,3,4], [3,4,0]]

  def wrapped_chunks(list) do
    last = Enum.at(list, -1)
    first2 = Enum.take(list, 2)

    [[last | first2]] ++ Enum.chunk_every(list, 3, 1, [hd(list)])
  end

  def apply_east(row) do
    row
    |> wrapped_chunks
    |> Enum.map(&east_rule/1)
  end

  def east_rule([:>, :., _]), do: :>
  def east_rule([_, :>, :.]), do: :.
  def east_rule([_, val, _]), do: val

  def apply_south(col) do
    col
    |> wrapped_chunks
    |> Enum.map(&south_rule/1)
  end

  def south_rule([:v, :., _]), do: :v
  def south_rule([_, :v, :.]), do: :.
  def south_rule([_, val, _]), do: val

  def move(lines, turn \\ 1)

  def move(lines, turn) do
    new_lines =
      lines
      |> Enum.map(&apply_east/1)
      |> Enum.zip_with(&apply_south/1)
      |> Enum.zip_with(& &1)

    if lines == new_lines do
      turn
    else
      move(new_lines, turn + 1)
    end
  end
end

input =
  IO.read(:eof)
  |> String.split()
  |> Enum.map(fn line ->
    line
    |> String.codepoints()
    |> Enum.map(&String.to_atom/1)
  end)

Day25.move(input)
|> IO.inspect()
