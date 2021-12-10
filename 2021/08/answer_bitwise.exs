import Bitwise

segment_to_bit = fn
  "a" -> 1 <<< 0
  "b" -> 1 <<< 1
  "c" -> 1 <<< 2
  "d" -> 1 <<< 3
  "e" -> 1 <<< 4
  "f" -> 1 <<< 5
  "g" -> 1 <<< 6
end

break_word_to_bits = fn word ->
  word
  |> String.codepoints()
  |> Enum.reduce(0, fn seg, bits ->
    bits ||| segment_to_bit.(seg)
  end)
end

parse_word_list = fn words ->
  words
  |> String.split(" ")
  |> Enum.map(break_word_to_bits)
end

parse_line = fn line ->
  [digit_patterns, output_value] =
    line
    |> String.trim()
    |> String.split(" | ")

  {
    parse_word_list.(digit_patterns),
    parse_word_list.(output_value)
  }
end

input =
  File.stream!("input.txt")
  |> Enum.map(parse_line)

# Part 1

bit_count = fn num ->
  for offset <- 0..7, bit = 1 <<< offset, (num &&& bit) > 0, reduce: 0 do
    acc -> acc + 1
  end
end

count_uniq_digits = fn {_, outputs} ->
  outputs
  |> Enum.filter(&(bit_count.(&1) in [2, 3, 4, 7]))
  |> Enum.count()
end

input
|> Enum.map(count_uniq_digits)
|> Enum.sum()
|> IO.inspect()

# Part 2

remove_bits = fn a, b ->
  a &&& bnot(b)
end

get_digit_map = fn digits ->
  digit_1 = Enum.find(digits, &(bit_count.(&1) == 2))
  digit_7 = Enum.find(digits, &(bit_count.(&1) == 3))
  digit_4 = Enum.find(digits, &(bit_count.(&1) == 4))
  digit_8 = Enum.find(digits, &(bit_count.(&1) == 7))

  digits_2_3_5 = Enum.filter(digits, &(bit_count.(&1) == 5))

  seg_a = digit_7 |> remove_bits.(digit_1)

  segs_a_d_g = Enum.reduce(digits_2_3_5, & &&&/2)

  seg_g = segs_a_d_g |> remove_bits.(seg_a) |> remove_bits.(digit_4)

  seg_d = segs_a_d_g |> remove_bits.(seg_a) |> remove_bits.(seg_g)

  seg_b = digit_4 |> remove_bits.(digit_1) |> remove_bits.(seg_d)

  [digit_5] = Enum.filter(digits_2_3_5, &((&1 &&& seg_b) > 0))

  seg_f =
    digit_5
    |> remove_bits.(seg_a)
    |> remove_bits.(seg_b)
    |> remove_bits.(seg_d)
    |> remove_bits.(seg_g)

  seg_c = digit_1 |> remove_bits.(seg_f)

  seg_e = digit_8 |> remove_bits.(digit_5) |> remove_bits.(seg_c)

  # We now know all the segments, so we can reconstruct the remaining digits
  digit_0 = digit_8 |> remove_bits.(seg_d)
  digit_6 = digit_8 |> remove_bits.(seg_c)
  digit_9 = digit_8 |> remove_bits.(seg_e)

  digit_3 = digit_9 |> remove_bits.(seg_b)

  digit_2 = digit_8 |> remove_bits.(seg_b) |> remove_bits.(seg_f)

  %{
    digit_0 => 0,
    digit_1 => 1,
    digit_2 => 2,
    digit_3 => 3,
    digit_4 => 4,
    digit_5 => 5,
    digit_6 => 6,
    digit_7 => 7,
    digit_8 => 8,
    digit_9 => 9
  }
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
