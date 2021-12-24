defmodule Day20 do
  use Bitwise

  def parse_algo(line) do
    line
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map(fn
      {".", i} -> {i, 0}
      {"#", i} -> {i, 1}
    end)
    |> Enum.into(%{})
  end

  def parse_image(image_lines) do
    image_lines
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {line, row} ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.map(fn
          {".", col} -> {{row, col}, 0}
          {"#", col} -> {{row, col}, 1}
        end)
    end)
    |> Enum.into(%{})
  end

  def image_bounds(image_map) do
    image_map
    |> Map.keys()
    |> Enum.map(&elem(&1, 0))
    |> Enum.min_max()
  end

  def pixel_square({row, col}) do
    for i <- -1..1, j <- -1..1 do
      {row + i, col + j}
    end
  end

  def calculate_pixel(pixel, algo, image, infinite_value) do
    algo_input =
      for pixel <- pixel_square(pixel) do
        Map.get(image, pixel, infinite_value)
      end
      |> Integer.undigits(2)

    algo[algo_input]
  end

  def enhance(_algo, image, _infinite_value, 0), do: image

  def enhance(algo, image, infinite_value, iter) do
    {min, max} = image_bounds(image)

    new_image =
      for row <- (min - 1)..(max + 1),
          col <- (min - 1)..(max + 1),
          pixel = {row, col},
          into: %{} do
        {pixel, calculate_pixel(pixel, algo, image, infinite_value)}
      end

    new_inf_value =
      List.duplicate(infinite_value, 9)
      |> Integer.undigits(2)
      |> then(&Map.get(algo, &1))

    enhance(algo, new_image, new_inf_value, iter - 1)
  end
end

[[algo_line], image_input] =
  IO.stream(:line)
  |> Enum.map(&String.trim/1)
  |> Enum.chunk_by(&(&1 == ""))
  |> Enum.reject(&(&1 == [""]))

algo = Day20.parse_algo(algo_line)

base_image = Day20.parse_image(image_input)

# Part 1
Day20.enhance(algo, base_image, 0, 2)
|> Map.values()
|> Enum.sum()
|> IO.inspect()

# Part 2
Day20.enhance(algo, base_image, 0, 50)
|> Map.values()
|> Enum.sum()
|> IO.inspect()
