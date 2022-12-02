require "../aoc"

AOC.day!(2)

enum Play
  Rock     = 1
  Paper    = 2
  Scissors = 3
end

enum Outcome
  Lose = 0
  Draw = 3
  Win  = 6
end

BEATS = {
  Play::Rock     => Play::Paper,
  Play::Paper    => Play::Scissors,
  Play::Scissors => Play::Rock,
}
LOSES_TO = BEATS.invert

def get_outcome(opponent, you)
  if opponent == you
    Outcome::Draw
  elsif BEATS[opponent] == you
    Outcome::Win
  else
    Outcome::Lose
  end
end

rounds = [] of {String, String}

AOC.each_line do |line|
  opponent, you = line.split(" ")
  rounds << {opponent, you}
end

def score_round(opponent : Play, you : Play)
  outcome = get_outcome(opponent, you)

  outcome.value + you.value
end

def force_outcome(opponent : Play, outcome : Outcome) : Play
  case outcome
  in Outcome::Draw
    # play same as opponent
    opponent
  in Outcome::Win
    BEATS[opponent]
  in Outcome::Lose
    LOSES_TO[opponent]
  end
end

opponent_mapping = {"A" => Play::Rock, "B" => Play::Paper, "C" => Play::Scissors}

AOC.part1 do
  part1_mapping = {"X" => Play::Rock, "Y" => Play::Paper, "Z" => Play::Scissors}

  plays = rounds.map do |opponent, you|
    {
      opponent_mapping[opponent],
      part1_mapping[you],
    }
  end

  plays.sum { |round| score_round(*round) }
end

AOC.part2 do
  part2_mapping = {"X" => Outcome::Lose, "Y" => Outcome::Draw, "Z" => Outcome::Win}

  plays = rounds.map do |opponent_symbol, outcome_symbol|
    outcome = part2_mapping[outcome_symbol]
    opponent = opponent_mapping[opponent_symbol]

    {
      opponent,
      force_outcome(opponent, outcome),
    }
  end

  plays.sum { |round| score_round(*round) }
end
