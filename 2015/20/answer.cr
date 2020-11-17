input = 33100000_i64

DIVISORS = {
  1_i64 => [1_i64],
  2_i64 => [2_i64, 1_i64],
}

def score(house : Int64) : Int64
  divisors(house).sum * 10
end

def divisors(number : Int64) : Array(Int64)
  # Find the smallest divisor of the number
  found_div = 1
  max = number
  div = 1
  while div < max
    div += 1
    if number % div == 0
      found_div = div
      break
    end
    max = number // div
  end

  if found_div == 1
    # must be prime
    DIVISORS[number] = [number, 1_i64]
  else
    next_highest = DIVISORS[number // div]

    new_divs = next_highest.dup + next_highest.map { |n| n * div }
    new_divs.uniq!.sort!.reverse!
    DIVISORS[number] = new_divs
  end
end

# Part 1
number = 3_i64
loop do
  break if score(number) >= input
  number += 1
end
pp number

# Part 2
def score2(house : Int64) : Int64
  divisors(house).select { |div|
    (house // div) <= 50
  }.sum * 11
end

loop do
  break if score2(number) >= input
  number += 1
end
pp number
pp score2(number)
