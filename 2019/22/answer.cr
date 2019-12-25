require "../expect"

# input = File.read("input.txt")

expect "Example 1.1", {10, 8, <<-SHUF}, 6
deal with increment 7
deal into new stack
deal into new stack
SHUF

expect "Example 1.2", {10, 0, <<-SHUF}, 0
deal with increment 7
deal into new stack
deal into new stack
SHUF

expect "Example 2.1", {10, 0, <<-SHUF}, 1
cut 6
deal with increment 7
deal into new stack
SHUF

expect "Example 2.2", {10, 5, <<-SHUF}, 6
cut 6
deal with increment 7
deal into new stack
SHUF

expect "Example 3.1", {10, 0, <<-SHUF}, 2
deal with increment 7
deal with increment 9
cut -2
SHUF

expect "Example 3.2", {10, 4, <<-SHUF}, 4
deal with increment 7
deal with increment 9
cut -2
SHUF

expect "Example 4.1", {10, 9, <<-SHUF}, 0
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
SHUF

puts answer(10007, 2019, File.read("input.txt"))

def answer(deck_size, card, shuffles)
  size = deck_size
  pos = card

  shuffles.each_line do |shuffle|
    case shuffle
    when "deal into new stack"
      # Just reverse the order
      pos = size - (pos + 1)
      pos
    when /deal with increment (\d+)/
      increment = $~[1].to_i
      pos = (pos * increment) % size
    when /cut (-?\d+)/
      offset = $~[1].to_i16
      if offset > pos
        pos += size
      end

      pos -= offset
      pos %= size
    end
  end
  pos
end
