defmodule Day18 do
  def explode(num_list, depth \\ 0)

  def explode(num, _depth) when is_integer(num) do
    {:ok, num}
  end

  def explode([l, r], depth) when is_integer(l) and is_integer(r) do
    if depth < 4 do
      {:ok, [l, r]}
    else
      {:explode, [l, 0, r]}
    end
  end

  def explode([l, r], depth) do
    case {
      explode(l, depth + 1),
      explode(r, depth + 1)
    } do
      {{:ok, _l}, {:ok, _r}} ->
        {:ok, [l, r]}

      {
        {:ok, _l},
        {:explode, [r_l, r_done, r_r]}
      } ->
        {:explode, [nil, [merge(l, r_l), r_done], r_r]}

      {
        {:explode, [l_l, l_done, l_r]},
        _right
      } ->
        {:explode, [l_l, [l_done, merge(l_r, r)], nil]}
    end
  end

  def merge(nil, r), do: r
  def merge(l, nil), do: l

  def merge(l, r) when is_integer(l) and is_integer(r) do
    l + r
  end

  def merge(num, [l, r]) when is_integer(num) do
    [merge(num, l), r]
  end

  def merge([l, r], num) when is_integer(num) do
    [l, merge(r, num)]
  end

  def split(num) when is_integer(num) and num < 10 do
    {:ok, num}
  end

  def split(num) when is_integer(num) and num >= 10 do
    {:split, [floor(num / 2), ceil(num / 2)]}
  end

  def split([l, r]) do
    case {split(l), split(r)} do
      {{:ok, _l}, {:ok, _r}} ->
        {:ok, [l, r]}

      {{:ok, _l}, {:split, r}} ->
        {:split, [l, r]}

      {{:split, l}, _right} ->
        {:split, [l, r]}
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

    {tree, []} = parse_tree(chars)

    tree
  end

  def parse_tree([d | rest]) when d in ~w[0 1 2 3 4 5 6 7 8 9] do
    {String.to_integer(d), rest}
  end

  def parse_tree(["[" | l_tree]) do
    {left_side, ["," | right_and_rest]} = parse_tree(l_tree)

    {right_side, ["]" | rest]} = parse_tree(right_and_rest)

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
