defmodule State do
  # Map:
  #
  #  0--1--2--3--4--5--6--7--8--9--10
  #        |     |     |     |
  #       11    12    13    14
  #       15    16     .     .
  #        .     .     .     .

  @base_map %{
    0 => [1],
    1 => [0, 2],
    2 => [1, 3, 11],
    3 => [2, 4],
    4 => [3, 5, 12],
    5 => [4, 6],
    6 => [5, 7, 13],
    7 => [6, 8],
    8 => [7, 9, 14],
    9 => [8, 10],
    10 => [9],
    11 => [2],
    12 => [4],
    13 => [6],
    14 => [8]
  }

  @stoppable_rooms [0, 1, 3, 5, 7, 9, 10]

  @base_desired_rooms %{
    a: [11],
    b: [12],
    c: [13],
    d: [14]
  }

  @energy %{
    a: 1,
    b: 10,
    c: 100,
    d: 1000
  }

  defstruct [:paths, :stoppable_rooms, :desired_rooms, :state, :desired_state, :energy]

  def path(state, a, b) do
    state.paths[{a, b}]
  end

  def apply_move(state, from, to) do
    {amphi, temp_state} = Map.pop!(state.state, from)
    %{state | state: Map.put(temp_state, to, amphi)}
  end

  def build_with_depth(input, depth) do
    map = add_to_map(@base_map, depth)
    paths = precompute_all_paths(map)

    desired_rooms = build_desired_rooms(@base_desired_rooms, depth)

    desired_state = build_desired_state(desired_rooms)

    %State{
      paths: paths,
      stoppable_rooms: @stoppable_rooms,
      desired_rooms: desired_rooms,
      state: input,
      desired_state: desired_state,
      energy: @energy
    }
  end

  defp add_to_map(map, 1) do
    map
  end

  defp add_to_map(map, depth) do
    prev_max = Map.keys(map) |> Enum.max()

    new_row = (prev_max + 1)..(prev_max + 4)

    new_map =
      for pos <- new_row, prev = pos - 4, reduce: map do
        map ->
          map
          |> Map.update!(prev, &[pos | &1])
          |> Map.put(pos, [prev])
      end

    add_to_map(new_map, depth - 1)
  end

  defp precompute_all_paths(map) do
    positions = Map.keys(map)

    for a <- positions, b <- positions, a != b, into: %{} do
      {{a, b}, find_path(map, a, [b])}
    end
  end

  defp find_path(_map, target, [target | path]) do
    path
  end

  defp find_path(map, target, [prev | rest] = path) do
    options = for opt <- map[prev], opt not in rest, do: opt

    if options == [] do
      nil
    else
      options
      |> Stream.map(&find_path(map, target, [&1 | path]))
      |> Stream.reject(&(&1 == nil))
      |> Enum.at(0)
    end
  end

  defp build_desired_rooms(rooms, 1) do
    rooms
  end

  defp build_desired_rooms(rooms, depth) do
    new_rooms = Map.map(rooms, fn {_, [max | rest]} -> [max + 4, max | rest] end)
    build_desired_rooms(new_rooms, depth - 1)
  end

  defp build_desired_state(desired_rooms) do
    Enum.map(desired_rooms, fn
      {k, vals} ->
        for v <- vals, do: {v, k}
    end)
    |> List.flatten()
    |> Map.new()
  end
end

defmodule Day23 do
  def min_energy(state, cur_min \\ nil, energy \\ 0)

  def min_energy(_state, cur_min, energy) when cur_min <= energy do
    cur_min
  end

  def min_energy(state, cur_min, energy) when state.state == state.desired_state do
    IO.puts("reached desired state: #{cur_min} -> #{energy}")
    energy
  end

  def min_energy(state, cur_min, energy) do
    case make_optimal_moves(state, cur_min, energy) do
      {energy, %State{desired_state: target, state: target}} ->
        IO.puts("reached desired state: #{cur_min} -> #{energy}")
        energy

      {energy, state} ->
        get_moves(state)
        |> Enum.reduce(cur_min, fn
          {new_state, energy_cost}, cur_min ->
            min(
              min_energy(new_state, cur_min, energy + energy_cost),
              cur_min
            )
        end)

      nil ->
        cur_min
    end
  end

  def get_moves(state) do
    for {pos, amphi} <- state.state, move <- other_moves(state, pos) do
      energy_cost = length(move) * state.energy[amphi]
      new_pos = Enum.at(move, -1)

      new_state = State.apply_move(state, pos, new_pos)

      {new_state, energy_cost}
    end
    |> Enum.sort_by(&elem(&1, 1), :asc)
  end

  def make_optimal_moves(_state, cur_min, energy) when cur_min <= energy do
    nil
  end

  def make_optimal_moves(state, cur_min, energy) do
    case find_optimal_move(state) do
      {pos, move} ->
        energy_cost = length(move) * state.energy[state.state[pos]]
        new_state = State.apply_move(state, pos, Enum.at(move, -1))

        make_optimal_moves(new_state, cur_min, energy + energy_cost)

      nil ->
        {energy, state}
    end
  end

  def find_optimal_move(state) do
    Map.keys(state.state)
    |> Enum.reduce_while(nil, fn
      pos, nil ->
        case optimal_move(state, pos) do
          nil -> {:cont, nil}
          move -> {:halt, move}
        end
    end)
  end

  def in_final_room?(state, pos) do
    amphi = state.state[pos]
    rooms = state.desired_rooms[amphi]

    rooms
    |> Enum.reduce_while(false, fn
      ^pos, _ ->
        {:halt, true}

      room, _ ->
        case state.state[room] do
          ^amphi -> {:cont, false}
          _ -> {:halt, false}
        end
    end)
  end

  def find_final_position(state, pos) do
    amphi = state.state[pos]
    rooms = state.desired_rooms[amphi]

    rooms
    |> Enum.reduce_while(false, fn
      room, _ ->
        cond do
          can_move?(state, pos, room) -> {:halt, room}
          state.state[room] == amphi -> {:cont, false}
          true -> {:halt, false}
        end
    end)
  end

  def optimal_move(state, pos) do
    cond do
      # No need to move
      in_final_room?(state, pos) ->
        nil

      # Going directly to the final room is the best move if available
      room = find_final_position(state, pos) ->
        {pos, State.path(state, pos, room)}

      # Otherwise, no optimal move
      true ->
        nil
    end
  end

  def other_moves(state, pos) do
    cond do
      in_final_room?(state, pos) ->
        []

      pos in state.stoppable_rooms ->
        []

      # Otherwise, list all valid moves to the hallway
      true ->
        for room <- state.stoppable_rooms, room != pos, can_move?(state, pos, room) do
          State.path(state, pos, room)
        end
    end
  end

  def can_move?(state, a, b) do
    for pos <- State.path(state, a, b) do
      state.state[pos] == nil
    end
    |> Enum.all?()
  end

  def parse_input(input) do
    [_ | amphipods] =
      Regex.run(
        ~r/
###(.)#(.)#(.)#(.)###
  #(.)#(.)#(.)#(.)#/,
        input
      )

    [a, b, c, d, e, f, g, h] =
      amphipods
      |> Enum.map(fn amphipod ->
        amphipod |> String.downcase() |> String.to_atom()
      end)

    %{
      11 => a,
      12 => b,
      13 => c,
      14 => d,
      15 => e,
      16 => f,
      17 => g,
      18 => h
    }
  end

  def unfold_part2(%{
        11 => a,
        12 => b,
        13 => c,
        14 => d,
        15 => e,
        16 => f,
        17 => g,
        18 => h
      }) do
    %{
      11 => a,
      12 => b,
      13 => c,
      14 => d,
      15 => :d,
      16 => :c,
      17 => :b,
      18 => :a,
      19 => :d,
      20 => :b,
      21 => :a,
      22 => :c,
      23 => e,
      24 => f,
      25 => g,
      26 => h
    }
  end
end

start_state =
  IO.read(:eof)
  |> Day23.parse_input()

# Part 1
start_state
|> State.build_with_depth(2)
|> Day23.min_energy()
|> IO.inspect()

# Part 2
start_state
|> Day23.unfold_part2()
|> State.build_with_depth(4)
|> Day23.min_energy()
|> IO.inspect()
