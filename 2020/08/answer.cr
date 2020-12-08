require "bit_array"

enum Operation
  Acc
  Jmp
  Nop
end

alias Instruction = {Operation, Int64}

instructions = [] of Instruction
File.each_line("input.txt") do |line|
  line =~ /(\w+) ([-+0-9]+)/

  instructions << {Operation.parse($1), $2.to_i64}
end

# Part 1
def simulate_program(instructions) : {Bool, Int64}
  executed = BitArray.new(instructions.size)
  acc = 0_i64
  ip = 0
  infinite = false

  loop do
    if ip >= instructions.size
      break
    end

    if executed[ip]
      infinite = true
      break
    end

    executed[ip] = true

    op, val = instructions[ip]
    case op
    when Operation::Acc
      acc += val
      ip += 1
    when Operation::Jmp
      ip += val
    when Operation::Nop
      ip += 1
    end
  end

  {infinite, acc}
end

puts simulate_program(instructions)[1]

# Part 2

def fix_corrupt_instruction(instructions) : Int64
  instructions.each_with_index do |(op, val), i|
    case op
    when Operation::Acc then next
    when Operation::Jmp, Operation::Nop
      new_instructions = instructions.dup

      new_instructions[i] = if op == Operation::Jmp
                              {Operation::Nop, val}
                            else
                              {Operation::Jmp, val}
                            end
      looped, result = simulate_program(new_instructions)

      if !looped
        return result
      end
    end
  end

  return -1_i64
end

puts fix_corrupt_instruction(instructions)
