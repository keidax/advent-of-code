input = File.read("input.txt").chomp
array : Array(Int32) = input.split(",").map &.to_i

def run(array, pos)
  opcode = array[pos]

  case opcode
  when 99
    return
  when 1, 2
    a_pos, b_pos, save_pos = array[pos + 1, 3]
    a, b = array[a_pos], array[b_pos]
    result = if opcode == 1
               a + b
             else
               a * b
             end
    array[save_pos] = result

    return run(array, pos + 4)
  else
    raise "unknown opcode #{opcode}"
  end
end

array[1] = 12
array[2] = 2

run(array, 0)

puts array[0]
