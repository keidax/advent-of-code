line_to_digits = fn line ->
    line
    |> String.trim
    |> String.codepoints
    |> Enum.map(&String.to_integer/1)
end

input = File.stream!("input.txt")
|> Enum.map(line_to_digits)

defmodule Answer do
  def most_common_bits(input) do
    half_count = length(input) / 2
    count_to_bit = fn
      count when count >= half_count -> 1
      _ -> 0
    end

    input
    |> Enum.zip_with(&Enum.sum/1)
    |> Enum.map(count_to_bit)
  end

  def flip_bits(digits) do
    Enum.map(digits, fn
      1 -> 0
      0 -> 1
    end)
  end

  def filter_by_bits([digits], _, _) do
    digits
  end

  def filter_by_bits(input, index, fun) do
    most_common_bit = most_common_bits(input) |> Enum.at(index)

    matching_input = Enum.filter(input, fn digits ->
      fun.(Enum.at(digits, index), most_common_bit)
    end)

    filter_by_bits(
      matching_input,
      index + 1,
      fun
    )
  end
end

# Part 1
gamma_bits = Answer.most_common_bits(input)
epsilon_bits = Answer.flip_bits(gamma_bits)

gamma = Integer.undigits(gamma_bits, 2)
epsilon = Integer.undigits(epsilon_bits, 2)

IO.inspect(epsilon * gamma)

# Part 2
o2_generator = Answer.filter_by_bits(input, 0, fn
  bit, most_common -> bit == most_common
end)
|> Integer.undigits(2)

co2_scrubber = Answer.filter_by_bits(input, 0, fn
  bit, most_common -> bit != most_common
end)
|> Integer.undigits(2)

IO.inspect(o2_generator * co2_scrubber)
