DIVISOR = 20201227

def find_loop_size(subject : UInt64, output)
  value = 1_u64
  loop_size = 0

  until value == output
    value = (value * subject) % DIVISOR
    loop_size += 1
  end

  loop_size
end

def transform(subject : UInt64, loop_size)
  value = 1_u64

  loop_size.times do
    value = (value * subject) % DIVISOR
  end

  value
end

# inputs:
# 8252394
# 6269621

# Part 1
loop_size = find_loop_size(7, 8252394)
puts transform(6269621, loop_size)
