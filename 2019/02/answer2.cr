input = File.read("input.txt").chomp
array : Array(Int32) = input.split(",").map &.to_i

def run(array, pos)
  opcode = array[pos]

  case opcode
  when 99
    return
  when 1, 2
    a_pos, b_pos, save_pos = array[pos+1, 3]
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

ANSWER = 19690720

def test(input, noun, verb) : Bool
  array = input.clone
  array[1] = noun
  array[2] = verb

  print '.'
  run(array, 0)

  array[0] == ANSWER
end

(0..99).each do |noun|
  (0..99).each do |verb|
    if test(array, noun, verb)
      puts "\n#{noun * 100 + verb}"
    end
  end
end
