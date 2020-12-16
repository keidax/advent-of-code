INPUT = [11, 18, 0, 20, 1, 7, 16]

def find_number_spoken(turn)
  last_spoken = Array(Int32).new(size: turn, value: -1)

  INPUT.each_with_index do |num, i|
    last_spoken[num] = i
  end

  i = INPUT.size
  last = INPUT.last

  while i < turn
    prev_turn = last_spoken.unsafe_fetch(last)

    # Delay updating the age of the most recently spoken number
    # until we've retrieved the previous age
    last_spoken[last] = i - 1

    if prev_turn >= 0
      last = (i - prev_turn - 1)
    else
      last = 0
    end

    i += 1
  end

  last
end

# Part 1
puts find_number_spoken(2020)

# Part 2
puts find_number_spoken(30_000_000)
