require_relative "aoc"

class SequenceTree
  def initialize(height)
    @height = height
    @children = Array.new(19, nil)
  end

  def new_child
    if @height > 1
      SequenceTree.new(@height - 1)
    else
      SequenceCounter.new
    end
  end

  def store(seq, id, price)
    change = seq[-@height]
    next_level = @children[change] ||= new_child
    next_level.store(seq, id, price)
  end

  def max
    @children.map { _1&.max || 0 }.max
  end
end

class SequenceCounter
  def initialize
    @sum_cache = {}
  end

  def store(_seq, id, price)
    unless @sum_cache.key?(id)
      @sum_cache[id] = price
    end
  end

  def max
    @sum_cache.values.sum
  end
end

SEQUENCE_TREE = SequenceTree.new(4)

class Buyer
  attr_reader :secrets, :prices, :price_changes

  def initialize(secret)
    @initial_secret = secret

    @secrets = [@initial_secret]

    prev_secret = @initial_secret
    prev_price = @initial_secret % 10
    price_changes = []

    2000.times do
      new_secret = next_secret(prev_secret)
      new_price = new_secret % 10

      @secrets << new_secret
      price_changes << (new_price - prev_price)

      if price_changes.size == 4
        SEQUENCE_TREE.store(price_changes, @initial_secret, new_price)
        price_changes.shift
      end

      prev_secret = new_secret
      prev_price = new_price
    end
  end

  def next_secret(secret)
    secret = (secret ^ (secret << 6)) % 16777216
    secret = (secret ^ (secret >> 5)) % 16777216
    (secret ^ (secret << 11)) % 16777216
  end
end

input = AOC.day(22)
initial_secrets = input.lines(chomp: true).map(&:to_i)
buyers = initial_secrets.map { Buyer.new(_1) }

AOC.part1 do
  buyers.sum { _1.secrets[2000] }
end

AOC.part2 do
  SEQUENCE_TREE.max
end
