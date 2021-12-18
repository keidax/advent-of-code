defmodule Day18 do
  def explode(num_list, depth \\ 0)

  def explode([l, r], depth) when is_integer(l) and is_integer(r) do
    if depth < 4 do
      # No explode needed
      {:ok, [l, r]}
    else
      {:explode, [l, 0, r]}
    end
  end

  def explode([l, r_list], depth) when is_integer(l) and is_list(r_list) do
    case explode(r_list, depth + 1) do
      {:ok, r} ->
        {:ok, [l, r]}

      {:explode, [r_l, r_done, r_r]} when is_integer(r_l) ->
        {:explode, [nil, [l + r_l, r_done], r_r]}

      {:explode, [nil, r_done, r_r]} ->
        {:explode, [nil, [l, r_done], r_r]}
    end
  end

  def explode([l_list, r], depth) when is_list(l_list) and is_integer(r) do
    case explode(l_list, depth + 1) do
      {:ok, l} ->
        {:ok, [l, r]}

      {:explode, [l_l, l_done, l_r]} when is_integer(l_r) ->
        {:explode, [l_l, [l_done, l_r + r], nil]}

      {:explode, [l_l, l_done, nil]} ->
        {:explode, [l_l, [l_done, r], nil]}
    end
  end

  def explode([l_list, r_list], depth) when is_list(l_list) and is_list(r_list) do
    case explode(l_list, depth + 1) do
      {:ok, l} ->
        explode_right(l, r_list, depth)

      {:explode, [l_l, l_done, l_r]} when is_integer(l_r) ->
        {:explode, [l_l, [l_done, add_from_left(l_r, r_list)], nil]}

      {:explode, [l_l, l_done, nil]} ->
        {:explode, [l_l, [l_done, r_list], nil]}
    end
  end

  def explode_right(l_list, r_list, depth) do
    case explode(r_list, depth + 1) do
      {:ok, r} ->
        {:ok, [l_list, r]}

      {:explode, [r_l, r_done, r_r]} when is_integer(r_l) ->
        {:explode, [nil, [add_from_right(l_list, r_l), r_done], r_r]}

      {:explode, [nil, r_done, r_r]} ->
        {:explode, [nil, [l_list, r_done], r_r]}
    end
  end

  def add_from_left(num, [l, r]) when is_integer(l) do
    [l + num, r]
  end

  def add_from_left(num, [l, r]) do
    [add_from_left(num, l), r]
  end

  def add_from_right([l, r], num) when is_integer(r) do
    [l, r + num]
  end

  def add_from_right([l, r], num) do
    [l, add_from_right(r, num)]
  end

  def split(num) when is_integer(num) and num < 10 do
    {:ok, num}
  end

  def split(num) when is_integer(num) and num >= 10 do
    {:split, [floor(num / 2), ceil(num / 2)]}
  end

  def split([l, r]) do
    case split(l) do
      {:ok, l} -> split_right(l, r)
      {:split, new_l} -> {:split, [new_l, r]}
    end
  end

  def split_right(l, r) do
    case split(r) do
      {:ok, r} -> {:ok, [l, r]}
      {:split, new_r} -> {:split, [l, new_r]}
    end
  end

  def reduce(num) do
    case explode(num) do
      {:explode, [_, new_num, _]} -> reduce(new_num)
      {:ok, num} -> reduce_split(num)
    end
  end

  def reduce_split(num) do
    case split(num) do
      {:split, new_num} -> reduce(new_num)
      {:ok, num} -> num
    end
  end

  def add(l, r) do
    reduce([l, r])
  end

  def parse(line) do
    chars =
      line
      |> String.trim()
      |> String.codepoints()

    {tree, []} = build_tree(chars)

    tree
  end

  def build_tree([d | rest]) when d in ~w[0 1 2 3 4 5 6 7 8 9] do
    {String.to_integer(d), rest}
  end

  def build_tree(["[" | l_tree]) do
    {left_side, ["," | right_and_rest]} = build_tree(l_tree)

    {right_side, ["]" | rest]} = build_tree(right_and_rest)

    {[left_side, right_side], rest}
  end

  def magnitude(n) when is_integer(n), do: n

  def magnitude([l, r]) do
    3 * magnitude(l) + 2 * magnitude(r)
  end
end

nums =
  IO.stream(:line)
  |> Enum.map(&Day18.parse/1)

# Part 1
nums
|> Enum.reduce(fn num, acc -> Day18.add(acc, num) end)
|> Day18.magnitude()
|> IO.inspect()

# Part 2
for x <- nums, y <- nums, x != y do
  Day18.add(x, y)
  |> Day18.magnitude()
end
|> Enum.max()
|> IO.inspect()
