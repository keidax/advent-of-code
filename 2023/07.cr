require "./aoc"

AOC.day!(7)

enum Card
  Two
  Three
  Four
  Five
  Six
  Seven
  Eight
  Nine
  Ten
  Jack
  Queen
  King
  Ace

  def self.new(card : Char)
    case card
    when '2' then Two
    when '3' then Three
    when '4' then Four
    when '5' then Five
    when '6' then Six
    when '7' then Seven
    when '8' then Eight
    when '9' then Nine
    when 'T' then Ten
    when 'J' then Jack
    when 'Q' then Queen
    when 'K' then King
    when 'A' then Ace
    else          raise ArgumentError.new("No card matching '#{card}'")
    end
  end

  def <=>(other, jokers)
    return self <=> other unless jokers

    case {self, other}
    when {Jack, Jack}
      0
    when {Jack, _}
      -1
    when {_, Jack}
      1
    else
      self <=> other
    end
  end
end

enum HandType
  HighCard
  OnePair
  TwoPair
  ThreeOfAKind
  FullHouse
  FourOfAKind
  FiveOfAKind
end

alias Cards = Tuple(Card, Card, Card, Card, Card)

class Hand
  property cards : Cards
  property bid : Int32

  def initialize(line : String)
    cards, bid = line.split(" ")

    @bid = bid.to_i
    @cards = Cards.from(cards.chars.map(&->Card.new(Char)))
  end

  def hand_type(jokers = false) : HandType
    return hand_type_with_jokers if jokers

    @hand_type ||= begin
      card_counts = @cards.tally.values.sort.reverse

      case card_counts
      when [5]
        HandType::FiveOfAKind
      when [4, 1]
        HandType::FourOfAKind
      when [3, 2]
        HandType::FullHouse
      when [3, 1, 1]
        HandType::ThreeOfAKind
      when [2, 2, 1]
        HandType::TwoPair
      when [2, 1, 1, 1]
        HandType::OnePair
      when [1, 1, 1, 1, 1]
        HandType::HighCard
      else
        raise "No matching hand type for #{@cards}"
      end
    end
  end

  private def hand_type_with_jokers : HandType
    @hand_type_with_jokers ||= begin
      tally = @cards.tally

      joker_count = tally.delete(Card::Jack) || 0
      return hand_type(false) if joker_count == 0

      card_counts = tally.values.sort.reverse

      case {joker_count, card_counts}
      when {1, [4]},
           {2, [3]},
           {3, [2]},
           {4, [1]},
           {5, _}
        HandType::FiveOfAKind
      when {1, [3, 1]},
           {2, [2, 1]},
           {3, [1, 1]}
        HandType::FourOfAKind
      when {1, [2, 2]}
        HandType::FullHouse
      when {1, [2, 1, 1]},
           {2, [1, 1, 1]}
        HandType::ThreeOfAKind
      when {1, [1, 1, 1, 1]}
        HandType::OnePair
      else
        raise "No matching hand type for #{@cards}"
      end
    end
  end

  def <=>(other : Hand, jokers = false)
    other_type_comp = hand_type(jokers) <=> other.hand_type(jokers)
    return other_type_comp if other_type_comp != 0

    card_comps = @cards.zip(other.cards).map { |c, o| c.<=>(o, jokers) }
    card_comps.reject!(0)

    if card_comps.any?
      card_comps[0]
    else
      0
    end
  end
end

def winnings(sorted_hands)
  sorted_hands.map_with_index do |hand, i|
    hand.bid * (i + 1)
  end.sum
end

hands = AOC.lines.map(&->Hand.new(String))

AOC.part1 do
  winnings(hands.sort)
end

AOC.part2 do
  winnings(
    hands.sort { |a, b| a.<=>(b, jokers: true) }
  )
end
