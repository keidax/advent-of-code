defmodule Dirac do
  def frequencies do
    for a <- 1..3, b <- 1..3, c <- 1..3 do
      a + b + c
    end
    |> Enum.frequencies()
  end
end

defmodule Day21 do
  defmodule Cycle do
    def start(enum) do
      cycle_pid =
        spawn_link(fn ->
          Stream.cycle(enum)
          |> Stream.each(fn elem ->
            receive do
              caller when is_pid(caller) -> send(caller, {self(), elem})
            end
          end)
          |> Stream.run()
        end)

      spawn_link(fn -> loop(cycle_pid, 0) end)
    end

    defp loop(cycle_pid, count) do
      receive do
        {:get, caller} ->
          send(cycle_pid, self())

          receive do
            {^cycle_pid, elem} -> send(caller, {self(), elem})
          end

          loop(cycle_pid, count + 1)

        {:count, caller} ->
          send(caller, {self(), count})

          loop(cycle_pid, count)
      end
    end

    def get(pid) do
      send(pid, {:get, self()})

      receive do
        {^pid, elem} -> elem
      end
    end

    def count(pid) do
      send(pid, {:count, self()})

      receive do
        {^pid, count} -> count
      end
    end
  end

  def next_player(1), do: 2
  def next_player(2), do: 1

  def run_game(player_map, player_turns, die) do
    player = Cycle.get(player_turns)
    {pos, score} = player_map[player]

    roll_sum = 1..3 |> Enum.map(fn _ -> Cycle.get(die) end) |> Enum.sum()

    next_pos = rem(pos + roll_sum - 1, 10) + 1
    next_score = score + next_pos

    new_map = %{player_map | player => {next_pos, next_score}}

    if next_score >= 1000 do
      {player, new_map}
    else
      run_game(new_map, player_turns, die)
    end
  end

  @rolls Dirac.frequencies()

  def run_copies(player_map, player, copies) do
    @rolls
    |> Enum.map(fn
      {roll, count} ->
        new_map = update_map(player_map, player, roll)

        player_won? = new_map[player] |> elem(1) >= 21

        cond do
          player_won? ->
            %{player => count * copies}

          copies <= 10 ->
            Task.async(fn -> run_copies(new_map, next_player(player), count * copies) end)

          true ->
            run_copies(new_map, next_player(player), count * copies)
        end
    end)
    |> Enum.reduce(%{}, fn
      elem, acc ->
        res =
          case elem do
            task when is_struct(task) -> Task.await(task, :infinity)
            _ -> elem
          end

        Map.merge(res, acc, fn _k, v1, v2 -> v1 + v2 end)
    end)
  end

  def update_map(map, player, roll) do
    {pos, score} = map[player]

    next_pos = rem(pos + roll - 1, 10) + 1
    next_score = score + next_pos

    %{map | player => {next_pos, next_score}}
  end
end

input =
  IO.stream(:line)
  |> Enum.map(fn
    line ->
      [_, player, pos] = Regex.run(~r/Player (\d) starting position: (\d)/, line)

      player = String.to_integer(player)
      pos = String.to_integer(pos)

      # Score always starts at 0
      {player, {pos, 0}}
  end)
  |> Enum.into(%{})

# Part 1
turns = Day21.Cycle.start([1, 2])
die = Day21.Cycle.start(1..100)

{winner, final_state} = Day21.run_game(input, turns, die)

loser =
  case winner do
    1 -> 2
    2 -> 1
  end

{_, loser_score} = final_state[loser]

IO.inspect(loser_score * Day21.Cycle.count(die))

# Part 2
win_counts = Day21.run_copies(input, 1, 1)

win_counts
|> Map.values()
|> Enum.max()
|> IO.inspect()
