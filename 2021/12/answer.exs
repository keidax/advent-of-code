defmodule Day12 do
  # Agent-based memoization cache
  defmodule Cache do
    use Agent

    def start_link do
      Agent.start_link(fn -> %{} end, name: __MODULE__)
    end

    def get(key) do
      Agent.get(__MODULE__, &Map.get(&1, key))
    end

    def update(key, value) do
      Agent.update(__MODULE__, &Map.put(&1, key, value))
    end
  end

  # Add a bidirectional path between 2 caves
  def add_path(caves, cave1, cave2) do
    caves
    |> Map.update(cave1, [cave2], &[cave2 | &1])
    |> Map.update(cave2, [cave1], &[cave1 | &1])
  end

  def small_cave?(cave) do
    cave =~ ~r/^[[:lower:]]/
  end

  def add_cave_if_small(cave, cave_list) do
    if small_cave?(cave) do
      [cave | cave_list]
    else
      cave_list
    end
  end

  # Calculate the path count, and save the value in the cache
  def count_paths_cached(caves, curr_cave, visited_small_caves, extra_visits) do
    key = [curr_cave, extra_visits | visited_small_caves]

    count = Cache.get(key)

    if count do
      count
    else
      count = count_paths(caves, curr_cave, visited_small_caves, extra_visits)
      Cache.update(key, count)
      count
    end
  end

  # Recursively calculate how many distinct paths exist from the current cave to the end cave.
  # visited_small_caves is a list of small caves that have already been visited, and cannot be visited again.
  # extra_visits is the total number of times any small cave can be revisited.
  def count_paths(caves, curr_cave, visited_small_caves \\ [], extra_visits)

  # Base case for recursion
  def count_paths(_caves, "end", _, _), do: 1

  def count_paths(caves, curr_cave, visited_small_caves, 0) do
    paths = caves[curr_cave]

    viable_paths = paths -- visited_small_caves

    next_small_caves = add_cave_if_small(curr_cave, visited_small_caves)

    viable_paths
    |> Enum.reduce(0, fn next_cave, acc ->
      acc + count_paths_cached(caves, next_cave, next_small_caves, 0)
    end)
  end

  def count_paths(caves, curr_cave, visited_small_caves, extra_visits) do
    paths = caves[curr_cave]

    viable_paths = paths -- visited_small_caves

    next_small_caves = add_cave_if_small(curr_cave, visited_small_caves)

    if small_cave?(curr_cave) && curr_cave != "start" do
      viable_paths
      |> Enum.reduce(0, fn next_cave, acc ->
        # Count the possible paths if the current small cave may be visited again
        with_revisit = count_paths_cached(caves, next_cave, visited_small_caves, extra_visits - 1)

        # Count the possible paths if the current small cave may NOT be visited again
        without_revisit = count_paths_cached(caves, next_cave, next_small_caves, extra_visits)

        # The previous 2 calculations have some double counting: the number of paths where the current cave is not
        # revisited, even if it could have been. Find that number and remove it.
        double_counted = count_paths_cached(caves, next_cave, next_small_caves, extra_visits - 1)
        acc + with_revisit + without_revisit - double_counted
      end)
    else
      viable_paths
      |> Enum.reduce(0, fn next_cave, acc ->
        acc + count_paths(caves, next_cave, next_small_caves, extra_visits)
      end)
    end
  end
end

input =
  File.stream!("input.txt")
  |> Enum.map(fn line ->
    line |> String.trim() |> String.split("-")
  end)
  |> Enum.reduce(%{}, fn [a, b], caves ->
    Day12.add_path(caves, a, b)
  end)

# Part 1
Day12.Cache.start_link()

Day12.count_paths(input, "start", 0)
|> IO.inspect()

# Part 2
Day12.count_paths(input, "start", 1)
|> IO.inspect()
