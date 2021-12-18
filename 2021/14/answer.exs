input =
  IO.stream(:line)
  |> Enum.map(&String.trim/1)

[[polymer_template], rule_input] =
  input
  |> Enum.chunk_by(&(&1 == ""))
  |> Enum.reject(&(&1 == [""]))

polymer = polymer_template |> String.codepoints()

polymer_with_nils = [nil | polymer] ++ [nil]

polymer_pair_frequencies =
  polymer_with_nils
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(&List.to_tuple/1)
  |> Enum.frequencies()

# Instead of maintaining the state of the whole polymer, we just need to keep
# track of how often each pair of elements occurs.
#
# The rules for insertions map from a pair, to the two pairs created by
# inserting in the middle.
pairwise_rules =
  for rule <- rule_input, into: %{} do
    [_, l, r, insert] = Regex.run(~r/(\w)(\w) -> (\w)/, rule)

    {
      {l, r},
      [{l, insert}, {insert, r}]
    }
  end

elements =
  pairwise_rules
  |> Enum.flat_map(fn {{l, r}, _} -> [l, r] end)
  |> Enum.uniq()

# The first and last elements in the polymer are also stored as pairs with nil.
# These pairs map 1-to-1 to themselves, because no elements are added onto the
# beginning or end.
end_rules =
  elements
  |> Enum.reduce(%{}, fn
    elem, acc ->
      left_nil = {nil, elem}
      right_nil = {elem, nil}

      acc
      |> Map.put(left_nil, [left_nil])
      |> Map.put(right_nil, [right_nil])
  end)

rules = Map.merge(pairwise_rules, end_rules)

defmodule Day14 do
  def apply_rules(pair_freqs, rules) do
    for {pair, freq} <- pair_freqs,
        new_pair <- Map.fetch!(rules, pair),
        reduce: %{} do
      acc ->
        Map.update(acc, new_pair, freq, &(&1 + freq))
    end
  end

  def score_polymer_pairs(pair_freqs) do
    single_freqs =
      for {{l, r}, freq} <- pair_freqs,
          elem <- [l, r],
          elem != nil,
          reduce: %{} do
        acc ->
          Map.update(acc, elem, freq, &(&1 + freq))
      end

    {min, max} =
      single_freqs
      |> Map.values()
      |> Enum.min_max()

    # Every element is counted twice (once on the left side of a pair, and once
    # on the right). Therefore we need to halve the counts to get our final answer.
    div(max - min, 2)
  end
end

# Part 1
1..10
|> Enum.reduce(polymer_pair_frequencies, fn
  _n, freqs -> Day14.apply_rules(freqs, rules)
end)
|> Day14.score_polymer_pairs()
|> IO.inspect()

# Part 2
1..40
|> Enum.reduce(polymer_pair_frequencies, fn
  _n, freqs -> Day14.apply_rules(freqs, rules)
end)
|> Day14.score_polymer_pairs()
|> IO.inspect()
