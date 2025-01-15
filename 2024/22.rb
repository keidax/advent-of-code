require_relative "aoc"

class Buyer
  LOW_15_BITS = 2**15 - 1

  # SEQUENCE_TREE is a map of sequences of price changes to a map of the price
  # each buyer will sell at when that sequence is first seen. The price change
  # sequence is represented as a 20-bit integer instead of a 4-integer array.
  # This optimizes memory allocations and hash lookup speed. Buyers are mapped
  # by their initial secret value, which we assume is unique.
  SEQUENCE_TREE = Hash.new { |h, k| h[k] = {} }

  attr_reader :last_secret

  def initialize(secret)
    @initial_secret = secret

    prev_secret = @initial_secret
    prev_price = @initial_secret % 10
    price_changes = 0

    2000.times do |i|
      new_secret = next_secret(prev_secret)
      new_price = new_secret % 10

      # make sure price_change is in the range 0..18
      price_change = (new_price - prev_price) + 9
      # price_change requires 5 bits
      price_changes = (price_changes << 5) | price_change

      if i >= 3
        SEQUENCE_TREE[price_changes][@initial_secret] ||= new_price
        price_changes &= LOW_15_BITS
      end

      prev_secret = new_secret
      prev_price = new_price
    end

    @last_secret = prev_secret
  end

  def next_secret(secret)
    secret = (secret ^ (secret << 6)) % 16777216
    secret = (secret ^ (secret >> 5)) % 16777216
    (secret ^ (secret << 11)) % 16777216
  end

  def self.max_bananas
    SEQUENCE_TREE.values.map { _1.values.sum }.max
  end
end

input = AOC.day(22)
initial_secrets = input.lines(chomp: true).map(&:to_i)
buyers = initial_secrets.map { Buyer.new(_1) }

AOC.part1 do
  buyers.sum(&:last_secret)
end

AOC.part2 do
  Buyer.max_bananas
end
