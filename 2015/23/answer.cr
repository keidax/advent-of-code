alias Registers = Hash(String, Int32)

abstract class Instruction
  # Return an integer for a relative jump, or nil to advance
  # to the next instruction.
  abstract def run(registers : Registers) : Int32?
end

class Half < Instruction
  @register : String

  def initialize(@register)
  end

  def run(registers) : Int32?
    registers[@register] //= 2
    nil
  end
end

class Triple < Instruction
  @register : String

  def initialize(@register)
  end

  def run(registers) : Int32?
    registers[@register] *= 3
    nil
  end
end

class Increment < Instruction
  @register : String

  def initialize(@register)
  end

  def run(registers) : Int32?
    registers[@register] += 1
    nil
  end
end

class Jump < Instruction
  @offset : Int32

  def initialize(@offset)
  end

  def run(registers) : Int32?
    return @offset
  end
end

class JumpEven < Instruction
  @register : String
  @offset : Int32

  def initialize(@register, @offset)
  end

  def run(registers) : Int32?
    if registers[@register] % 2 == 0
      @offset
    else
      nil
    end
  end
end

class JumpOne < Instruction
  @register : String
  @offset : Int32

  def initialize(@register, @offset)
  end

  def run(registers) : Int32?
    if registers[@register] == 1
      @offset
    else
      nil
    end
  end
end

program = [] of Instruction

File.each_line("input.txt") do |line|
  reg = "(\\w+)"
  off = "([-+]\\d+)"
  instruction = case line
                when /hlf #{reg}/
                  Half.new($1)
                when /tpl #{reg}/
                  Triple.new($1)
                when /inc #{reg}/
                  Increment.new($1)
                when /jmp #{off}/
                  Jump.new($1.to_i32)
                when /jie #{reg}, #{off}/
                  JumpEven.new($1, $2.to_i32)
                when /jio #{reg}, #{off}/
                  JumpOne.new($1, $2.to_i32)
                else
                  raise "unknown instruction: #{line}"
                end
  program << instruction
end

def run_program(program, registers)
  ip = 0

  while ip < program.size
    jump = program[ip].run(registers)

    if jump
      ip += jump
    else
      ip += 1
    end
  end
end

# Part 1
registers = {"a" => 0, "b" => 0}
run_program(program, registers)
puts registers["b"]

# Part 2
registers = {"a" => 1, "b" => 0}
run_program(program, registers)
puts registers["b"]
