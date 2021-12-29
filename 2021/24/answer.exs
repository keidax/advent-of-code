# A relatively brute-force solution, taking advantage of the fact that only the
# z register carries over between digits.
defmodule Day24 do
  def mystery_func({a, b, c}) do
    # inp w
    # mul x 0
    # add x z
    # mod x 26
    # div z {a}
    # add x {b}
    # eql x w
    # eql x 0
    # mul y 0
    # add y 25
    # mul y x
    # add y 1
    # mul z y
    # mul y 0
    # add y w
    # add y {c}
    # mul y x
    # add z y

    fn z, w ->
      x =
        if rem(z, 26) + b == w do
          0
        else
          1
        end

      y = 25 * x + 1

      z = div(z, a) * y

      z + (w + c) * x
    end
  end
end

params = [
  {1, 10, 2},
  {1, 10, 4},
  {1, 14, 8},
  {1, 11, 7},
  {1, 14, 12},
  {26, -14, 7},
  {26, 0, 10},
  {1, 10, 14},
  {26, -10, 2},
  {1, 13, 6},
  {26, -12, 8},
  {26, -3, 11},
  {26, -11, 5},
  {26, -2, 11}
]

params
|> Enum.map(&Day24.mystery_func/1)
|> Enum.reduce(%{0 => {0, 0}}, fn
  func, map ->
    for {z, {prev_max, prev_min}} <- map, digit <- 1..9, reduce: %{} do
      map ->
        out_z = func.(z, digit)

        max_input = prev_max * 10 + digit
        min_input = prev_min * 10 + digit

        Map.update(map, out_z, {max_input, min_input}, fn {max2, min2} ->
          {max(max_input, max2), min(min_input, min2)}
        end)
    end
end)
|> Access.get(0)
|> IO.inspect()
