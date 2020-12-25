decks = File.read_lines("input.txt")
  .chunks { |line| Enumerable::Chunk::Drop if line.blank? }
  .map { |_, cards| cards[1..].map &.to_u8 }
  .map { |deck| Deque.new(deck) }

original_decks = decks.clone

def score(deck)
  deck = deck.dup
  score = 0_i64

  while deck.any?
    score += deck.size * deck.shift
  end

  score
end

# Part 1
while decks.none? &.empty?
  card0 = decks[0].shift
  card1 = decks[1].shift

  if card0 > card1
    decks[0] << card0 << card1
  else
    decks[1] << card1 << card0
  end
end

winning_deck = decks.find(&.any?).not_nil!

puts score(winning_deck)

# Part 2
def recursive_combat(deck0, deck1) : Int32
  prev_rounds = Set({Deque(UInt8), Deque(UInt8)}).new

  until deck0.empty? || deck1.empty?
    # FIXME: is there a faster way to store previous rounds?
    unless prev_rounds.add?({deck0.dup, deck1.dup})
      # Instant win for player 1
      return 0
    end

    card0 = deck0.shift
    card1 = deck1.shift

    if deck0.size >= card0 && deck1.size >= card1
      rec_deck0 = deck0.dup
      rec_deck0.pop(deck0.size - card0)

      rec_deck1 = deck1.dup
      rec_deck1.pop(deck1.size - card1)

      winner = recursive_combat(rec_deck0, rec_deck1)
    elsif card0 > card1
      winner = 0
    else
      winner = 1
    end

    if winner == 0
      deck0 << card0 << card1
    else
      deck1 << card1 << card0
    end
  end

  if deck0.empty?
    1
  else
    0
  end
end

deck0, deck1 = original_decks[0], original_decks[1]
winner = recursive_combat(deck0, deck1)

winning_deck = [deck0, deck1][winner]
puts score(winning_deck)
