require "./aoc"

AOC.day!(2)

alias Draw = {red: Int32, green: Int32, blue: Int32}
alias Game = NamedTuple(id: Int32, draws: Array(Draw))

def load_games : Array(Game)
  AOC.lines.map do |line|
    game_header, draw_text = line.split(": ")
    id = game_header.match!(/\d+/)[0].to_i

    draws = draw_text.split("; ").map do |draw|
      r = draw.match(/(\d+) red/).try(&.[1].to_i) || 0
      g = draw.match(/(\d+) green/).try(&.[1].to_i) || 0
      b = draw.match(/(\d+) blue/).try(&.[1].to_i) || 0

      {red: r, green: g, blue: b}
    end

    {id: id, draws: draws}
  end
end

def possible?(game, max_draw)
  game[:draws].all? do |draw|
    draw[:red] <= max_draw[:red] &&
      draw[:green] <= max_draw[:green] &&
      draw[:blue] <= max_draw[:blue]
  end
end

def minimum_power(game) : Int32
  red = game[:draws].max_of(&.[:red])
  green = game[:draws].max_of(&.[:green])
  blue = game[:draws].max_of(&.[:blue])

  red * green * blue
end

AOC.part1 do
  load_games
    .select { |game| possible?(game, {red: 12, green: 13, blue: 14}) }
    .sum(&.[:id])
end

AOC.part2 do
  load_games.map(&->minimum_power(Game)).sum
end
