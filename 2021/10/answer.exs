input =
  for line <- IO.stream(:line) do
    line |> String.trim() |> String.codepoints()
  end

defmodule Answer do
  def reduce_line([], stack) do
    {:done, stack}
  end

  def reduce_line([open_char | tail], stack)
      when open_char in ~w'( [ { <' do
    reduce_line(tail, [open_char | stack])
  end

  def reduce_line([close_char | tail], [open_char | stack])
      when (open_char <> close_char) in ~w'() [] {} <>' do
    reduce_line(tail, stack)
  end

  def reduce_line([close_char | _], _) do
    {:corrupt, close_char}
  end

  def score_pt1({:done, _}), do: 0
  def score_pt1({:corrupt, ")"}), do: 3
  def score_pt1({:corrupt, "]"}), do: 57
  def score_pt1({:corrupt, "}"}), do: 1197
  def score_pt1({:corrupt, ">"}), do: 25137

  def score_pt2({:corrupt, _}), do: 0
  def score_pt2({:done, stack}), do: score_pt2(stack, 0)
  def score_pt2([], score), do: score

  def score_pt2([char | stack], score) do
    char_value =
      case char do
        "(" -> 1
        "[" -> 2
        "{" -> 3
        "<" -> 4
      end

    score_pt2(stack, score * 5 + char_value)
  end
end

# Part 1
checked_lines = input |> Enum.map(&Answer.reduce_line(&1, []))

illegal_scores =
  checked_lines
  |> Enum.map(&Answer.score_pt1/1)

illegal_scores
|> Enum.sum()
|> IO.inspect()

# Part 2
completion_scores =
  checked_lines
  |> Enum.map(&Answer.score_pt2/1)
  |> Enum.reject(&(&1 == 0))
  |> Enum.sort()

middle = div(length(completion_scores), 2)

completion_scores
|> Enum.at(middle)
|> IO.inspect()
