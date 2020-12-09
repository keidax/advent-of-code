PREAMBLE_SIZE = 25
preamble = Deque(Int64).new
input = Deque(Int64).new

File.each_line("input.txt") do |line|
  num = line.to_i64

  if preamble.size < PREAMBLE_SIZE
    preamble << num
  else
    input << num
  end
end

def sum_of_two?(preamble, num) : Bool
  preamble.each_with_index do |a, i|
    preamble.each_with_index do |b, j|
      next if i == j

      return true if a + b == num
    end
  end

  false
end

def find_invalid(preamble, input) : Int64
  preamble = preamble.dup
  input = input.dup

  while sum_of_two?(preamble, input.first)
    preamble.shift
    preamble.push(input.shift)
  end
  input.first
end

def find_range(input, num) : Range(Int32, Int32)?
  sum = input[0] + input[1]
  start, finish = 0, 1

  until sum == num
    # Advance the start of the range by 1
    sum -= input[start]
    start += 1
    break if start == input.size - 1

    # If the range is too large, shrink from the end
    while sum > num && (finish - 1) > start
      sum -= input[finish]
      finish -= 1
    end

    # If the range is too small, grow from the end
    while sum < num && (finish + 1) < input.size
      finish += 1
      sum += input[finish]
    end
  end

  if sum == num
    (start..finish)
  end
end

# Part 1
invalid_num = find_invalid(preamble, input)
puts invalid_num

# Part 2
full_input = preamble + input
range = find_range(full_input, invalid_num).not_nil!
puts full_input.to_a[range].minmax.sum
