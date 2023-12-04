require "./aoc"

AOC.day!(4)

class Card
  @id : Int32
  @winning : Set(Int32)
  @numbers : Set(Int32)

  property instances = 1

  def initialize(line : String)
    md = line.match!(/Card \s*(\d+): (.*) \| (.*)/)

    @id = md[1].to_i
    @winning = md[2].strip.split(/\s+/).map(&.to_i).to_set
    @numbers = md[3].strip.split(/\s+/).map(&.to_i).to_set
  end

  def match_size
    @match_size ||= (@winning & @numbers).size
  end

  def points
    if match_size == 0
      0
    else
      2 ** (match_size - 1)
    end
  end
end

cards = AOC.lines.map(&->Card.new(String))

AOC.part1 { cards.sum(&.points) }

AOC.part2 do
  cards.each_with_index do |card, i|
    range = card.match_size

    cards[i + 1, range].each do |next_card|
      next_card.instances += card.instances
    end
  end

  cards.sum(&.instances)
end
