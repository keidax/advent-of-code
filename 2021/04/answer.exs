input =
  File.stream!("input.txt")
  |> Enum.map(&String.trim/1)

[[number_input] | board_input] =
  input
  |> Enum.chunk_by(&(&1 == ""))
  |> Enum.reject(&(&1 == [""]))

numbers =
  for num <- String.split(number_input, ",") do
    String.to_integer(num)
  end

# For quickly looking up the turn a number is played
number_map =
  for {n, index} <- Enum.with_index(numbers), into: %{} do
    # Add 1, since turn is 1-indexed
    {n, index + 1}
  end

boards =
  for row_input <- board_input do
    for row_string <- row_input do
      for row_num <- String.split(row_string) do
        String.to_integer(row_num)
      end
    end
  end

row_winning_turn = fn row ->
  get_turn_for_num = &Map.fetch!(number_map, &1)

  row
  |> Enum.map(get_turn_for_num)
  |> Enum.max()
end

board_winning_turn = fn rows ->
  cols =
    rows
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)

  (rows ++ cols)
  |> Enum.map(row_winning_turn)
  |> Enum.min()
end

score_at_turn = fn board, turn ->
  called_nums = Enum.take(numbers, turn)
  winning_num = List.last(called_nums)

  board_nums = List.flatten(board)
  uncalled_nums = board_nums -- called_nums

  Enum.sum(uncalled_nums) * winning_num
end

# Part 1
boards_by_turn =
  for board <- boards do
    {board, board_winning_turn.(board)}
  end

{{best_board, winning_turn}, {worst_board, last_turn}} =
  Enum.min_max_by(boards_by_turn, fn {_, turn} -> turn end)

IO.inspect(score_at_turn.(best_board, winning_turn))

# Part 2
IO.inspect(score_at_turn.(worst_board, last_turn))
