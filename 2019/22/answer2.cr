require "../expect"
require "big"

FACTORS = sieve(10_007)
puts "Found #{FACTORS.size} primes"

INPUT = File.read("input.txt")

deck_size = 119315717514047.to_i64
max_times = 101741582076661.to_i64

part_1_collapsed = collapse(INPUT, 10007).join('\n')

puts position_after_shuffle(10_007, 2019, INPUT)
puts card_after_shuffle(10_007, 4684, INPUT)
puts position_after_shuffle(10_007, 2019, part_1_collapsed)
puts card_after_shuffle(10_007, 4684, part_1_collapsed)

times_map = Hash(Int64, Array(String)).new
times_map[1] = collapse(INPUT, deck_size)

prev_times = 1_i64
while prev_times * 2 <= max_times
  times_map[prev_times * 2] = double_shuffle(times_map[prev_times], deck_size)
  prev_times *= 2
end

final_times = 0_i64
final_shuffle = [] of String
times_map.each_key.to_a.reverse.each do |key|
  while (max_times - final_times) >= key
    final_times += key
    final_shuffle.concat(times_map[key])
  end
end

final_shuffle = collapse(final_shuffle, deck_size)

puts answer(deck_size, 2020, final_shuffle.join("\n"))

def double_shuffle(shuffles, deck_size)
  shuffles = shuffles * 2
  shuffles = sort(shuffles, deck_size)
  collapse(shuffles, deck_size)
end

def answer(deck_size : Int64, position : Int64, shuffles : String) : Int64
  card_after_shuffle(deck_size, position, shuffles)
end

def sort(shuffles, size)
  if shuffles.is_a? String
    lines = shuffles.lines
  else
    lines = shuffles
  end

  loop do
    break if lines.size == 1

    changed = false
    lines.each_with_index do |line, i|
      next if i == 0

      sorted = can_sort?(lines[i - 1], line, size)
      if sorted
        lines[i - 1, 2] = sorted.to_a
        changed = true
      end
    end

    break unless changed
  end

  lines
end

def collapse(shuffles, size)
  lines = sort(shuffles, size)

  loop do
    changed = false

    break if lines.size == 1
    lines.each_with_index do |line, i|
      next if i == 0
      prev_line = lines[i - 1]

      collapsed = can_collapse?(prev_line, line, size)
      if collapsed.is_a?(String)
        lines[i - 1, 2] = collapsed
      elsif collapsed # is a tuple
        lines[i - 1, 2] = collapsed.to_a
      end

      if collapsed
        changed = true
        break
      end
    end

    break unless changed
  end

  lines
end

NEW       = "deal into new stack"
INCREMENT = /deal with increment (-?\d+)/
CUT       = /cut (-?\d+)/

def prev_match : Int64
  $~[1].to_i64
end

def extract(pattern, input) : Int64
  pattern.match(input).not_nil![1].to_i64
end

def sieve(n : Int64) : Array(Int64)
  ary = [] of Int64?
  ary.concat (2_i64..n).to_a

  ary.each_with_index do |num, i|
    next unless num

    idx = i.to_i64
    while idx + num + 1 < n
      idx += num
      ary[idx] = nil
    end
  end

  ary.compact
end

# Try to factor n with a list of primes.
# Concat to an existing array, for speed
def simple_factor(n, onto array)
  FACTORS.each do |f|
    break if f > (n // 2)

    while n % f == 0
      array << f
      n //= f
    end
  end
  array << n if n > 1
end

# returns (a * b) % n
def times_mod(a, b, n)
  # Make sure values are positive
  a += n if a < 0
  raise "unhandled negative" if b < 0

  factors = [] of Int64
  simple_factor a, onto: factors
  simple_factor b, onto: factors
  factors.sort!

  factors.unshift(factors.pop)
  factors = factors.map &.to_big_i

  factors.reduce(1.to_big_i) { |acc, i| (acc * i) % n }.to_i64
end

def mod_exp(base, exponent, modulus)
  result = 1.to_big_i
  base = base.to_big_i
  base %= modulus

  while exponent > 0
    if (exponent % 2) == 1
      result = (result * base) % modulus
    end

    exponent >>= 1
    base = (base * base) % modulus
  end

  result.to_i64
end

# reorder with increments, then cuts, then deals
def can_sort?(line1, line2, size)
  case {line1, line2}
  when {NEW, CUT}
    # deal into new stack
    # cut a
    # ==========
    # cut -a
    # deal into new stack
    cut = extract CUT, line2
    {"cut #{-cut}", NEW}
  when {CUT, INCREMENT}
    # cut a
    # deal with increment b
    # ==========
    # deal with increment b
    # cut (a * b) % size
    cut = extract CUT, line1
    inc = extract INCREMENT, line2
    new_cut = times_mod(cut, inc, size) # (cut * inc) % size

    {line2, "cut #{new_cut}"}
  when {NEW, INCREMENT}
    # deal into new stack
    # increment a
    # ==========
    # increment a
    # cut -(a - 1)
    # deal into new stack
    inc = extract INCREMENT, line2
    {
      "deal with increment #{inc}",
      "cut -#{inc - 1}",
      NEW,
    }
  else
    nil
  end
end

def can_collapse?(line1, line2, size) : {String, String} | String?
  case {line1, line2}
  when {CUT, CUT}
    # cut a
    # cut b
    # ==========
    # cut (a + b) % size
    cut1 = extract CUT, line1
    cut2 = extract CUT, line2
    new_cut = (cut1 + cut2) % size
    "cut #{new_cut}"
  when {NEW, NEW}
    # deal into new stack
    # deal into new stack
    # ==========
    # cut 0 (simplifies replacement logic)
    "cut 0"
  when {INCREMENT, INCREMENT}
    # deal with increment a
    # deal with increment b
    # ==========
    # deal with increment (a * b) % size
    inc1 = extract INCREMENT, line1
    inc2 = extract INCREMENT, line2
    new_inc = times_mod(inc1, inc2, size) # (inc1 * inc2) % size
    "deal with increment #{new_inc}"
  else
    nil
  end
end

# Assuming deck starts in factory order, returns the position that card ends up in after shuffling.
def position_after_shuffle(deck_size : Int64, card : Int64, shuffles) : Int64
  shuffles.each_line do |shuffle|
    case shuffle
    when "deal into new stack"
      card = deck_size - (card + 1)
    when /deal with increment (\d+)/
      increment = $~[1].to_i64
      card = (card * increment) % deck_size
    when /cut (-?\d+)/
      offset = $~[1].to_i64
      if offset > card
        card += deck_size
      end

      card -= offset
      card %= deck_size
    end
  end

  card
end

# Assuming deck starts in factory order, returns the card that ends up in position after shuffling.
def card_after_shuffle(deck_size : Int64, position : Int64, shuffles) : Int64
  # Trace through shuffles backwards to find the starting position of the card
  # that ends up in _position_.
  shuffles.lines.reverse.each do |shuffle|
    case shuffle
    when "deal into new stack"
      # Reverse position
      position = deck_size - (position + 1)
    when /deal with increment (\d+)/
      increment = $~[1].to_i64
      # puts "increment is #{increment}"
      # puts "deck_size is #{deck_size}"
      # puts "prev position is #{position}"

      mod_inv = mod_exp(increment, deck_size - 2, deck_size)
      # puts "mod inv is #{mod_inv}"

      # position = (position * mod_inv) % deck_size
      position = times_mod(position, mod_inv, deck_size)
      # puts "position is #{position}"
    when /cut (-?\d+)/
      offset = $~[1].to_i64

      position += offset
      position %= deck_size
    end
  end

  position
end
