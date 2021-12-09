# Each segment is represented as an atom (:a, :b, etc.). Each digit is
# represented as a list of segments. So 1, when unscrambled, would be [:c, :f].

# For convenience, we use lists instead of sets from MapSet. This means, when
# checking if two digits are equal, we must make sure the atoms are sorted.

break_word_to_atoms = fn word ->
  word
  |> String.codepoints()
  |> Enum.map(&String.to_atom/1)
  |> Enum.sort()
end

break_word_list_to_atoms = fn word_string ->
  word_string
  |> String.split(" ")
  |> Enum.map(break_word_to_atoms)
end

parse_line = fn line ->
  [digit_patterns, output_value] =
    line
    |> String.trim()
    |> String.split(" | ")

  {
    break_word_list_to_atoms.(digit_patterns),
    break_word_list_to_atoms.(output_value)
  }
end

input =
  File.stream!("input.txt")
  |> Enum.map(parse_line)

# Part 1
count_uniq_digits = fn {_, outputs} ->
  outputs
  |> Enum.map(fn
    # 1, 7, 4, or 8
    digit when length(digit) in [2, 3, 4, 7] -> 1
    # any other digit
    _ -> 0
  end)
  |> Enum.sum()
end

input
|> Enum.map(count_uniq_digits)
|> Enum.sum()
|> IO.inspect()

# Part 2

# Segment names:
#  aaaa
# b    c
# b    c
#  dddd
# e    f
# e    f
#  gggg

common_segments = fn digits ->
  expected_count = length(digits)

  digit_freqs =
    digits
    |> List.flatten()
    |> Enum.frequencies()

  for {segment, freq} <- digit_freqs, freq == expected_count, do: segment
end

get_digit_map = fn digits ->
  digit_1 = Enum.find(digits, &(length(&1) == 2))
  digit_7 = Enum.find(digits, &(length(&1) == 3))
  digit_4 = Enum.find(digits, &(length(&1) == 4))
  digit_8 = Enum.find(digits, &(length(&1) == 7))

  digits_2_3_5 = Enum.filter(digits, &(length(&1) == 5))
  # digits_0_6_9 = Enum.filter(digits, &length(&1) == 6)

  # Compare digits and groups of segments to incrementally deduce each segment
  # value

  [seg_a] = digit_7 -- digit_1

  segs_a_d_g = common_segments.(digits_2_3_5)

  [seg_g] = (segs_a_d_g -- [seg_a]) -- digit_4

  [seg_d] = segs_a_d_g -- [seg_a, seg_g]

  [seg_b] = (digit_4 -- digit_1) -- [seg_d]

  [digit_5] = Enum.filter(digits_2_3_5, &(seg_b in &1))

  [seg_f] = digit_5 -- [seg_a, seg_b, seg_d, seg_g]

  [seg_c] = digit_1 -- [seg_f]

  [seg_e] = digit_8 -- [seg_a, seg_b, seg_c, seg_d, seg_f, seg_g]

  # We now know all the segments, so we can reconstruct the remaining digits
  unsorted_map = %{
    [seg_a, seg_b, seg_c, seg_e, seg_f, seg_g] => 0,
    digit_1 => 1,
    [seg_a, seg_c, seg_d, seg_e, seg_g] => 2,
    [seg_a, seg_c, seg_d, seg_f, seg_g] => 3,
    digit_4 => 4,
    digit_5 => 5,
    [seg_a, seg_b, seg_d, seg_e, seg_f, seg_g] => 6,
    digit_7 => 7,
    digit_8 => 8,
    [seg_a, seg_b, seg_c, seg_d, seg_f, seg_g] => 9
  }

  # Make sure each digit's segments are sorted, for easy comparison
  unsorted_map
  |> Enum.map(fn {k, v} -> {Enum.sort(k), v} end)
  |> Enum.into(%{})
end

get_output_value = fn scrambled_digits, map ->
  scrambled_digits
  |> Enum.map(&Map.fetch!(map, &1))
  |> Integer.undigits()
end

input
|> Enum.map(fn {digits, values} ->
  map = get_digit_map.(digits)
  get_output_value.(values, map)
end)
|> Enum.sum()
|> IO.inspect()
