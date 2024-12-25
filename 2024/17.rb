require_relative "aoc"

class Computer
  attr_accessor :a, :b, :c
  attr_accessor :ip
  attr_accessor :prog
  attr_accessor :output

  def initialize(input, a = 0, b = 0, c = 0)
    if input.is_a?(AOC::Input)
      register_input, program_input = input.line_sections
      register_input.each do |reg_line|
        if /Register (\w): (\d+)/ =~reg_line
          reg = $1.downcase
          val = $2.to_i
          instance_variable_set(:"@#{reg}", val)
        end
      end
      _, code = program_input[0].split " "
      @prog = code.split(",").map(&:to_i)
    elsif input.is_a?(Array)
      @prog = input.dup
      @a = a
      @b = b
      @c = c
    end

    @ip = 0

    @output = []
  end

  def run_to_halt
    while @ip < (@prog.size - 1)
      run_instruction
    end
  end

  private

  def run_instruction
    opcode = @prog[@ip]
    operand = @prog[@ip + 1]

    case opcode
    when 0
      adv(operand)
    when 1
      bxl(operand)
    when 2
      bst(operand)
    when 3
      jnz(operand) and return
    when 4
      bxc(operand)
    when 5
      out(operand)
    when 6
      bdv(operand)
    when 7
      cdv(operand)
    end

    @ip += 2
  end

  def combo(operand)
    case operand
    when 0, 1, 2, 3
      operand
    when 4
      @a
    when 5
      @b
    when 6
      @c
    when 7
      raise "reserved combo operand 7"
    end
  end

  def adv(operand)
    num = @a
    denom = 2**combo(operand)

    @a = num / denom
  end

  def bxl(operand)
    @b = (@b ^ operand)
  end

  def bst(operand)
    @b = combo(operand) % 8
  end

  # return true if a jump occurred, false otherwise
  def jnz(operand)
    if @a == 0
      false
    else
      @ip = operand
      true
    end
  end

  def bxc(_)
    @b = (@b ^ @c)
  end

  def out(operand)
    @output << (combo(operand) % 8)
  end

  def bdv(operand)
    num = @a
    denom = 2**combo(operand)

    @b = num / denom
  end

  def cdv(operand)
    num = @a
    denom = 2**combo(operand)

    @c = num / denom
  end
end

input = AOC.day(17)

AOC.part1 do
  comp = Computer.new(input)
  comp.run_to_halt
  comp.output.join(",")
end

# Assume the program is structured such that on each iteration:
# - register A is shifted 3 bits to the right
# - the shifted bits are transformed in some way, possibly influenced
#   by the remaining bits of A
# - the program outputs the transformed bits
# - the program loops if A is not 0
#
# This means the most significant bits of A determine the final outputs. So we
# can work backwards:
# - set an initial value for A in the range 0..7
# - run the program and see if the outputs match the _end_ of the program values
# - when we find a potential match, shift A 3 bits to the left and recurse
#
# Eventually we'll either find a value of A that produces the entire program
# output and terminates, or we'll hit a dead end and backtrack up the stack.
def find_a(prog, a)
  (0..7).each do |x|
    possible_a = (a << 3) + x

    comp = Computer.new(prog, possible_a)
    comp.run_to_halt

    if prog == comp.output
      return possible_a
    elsif comp.output.size >= prog.size
      # too large
      next
    elsif possible_a == 0
      # don't recurse without at least one significant bit
      next
    elsif ends_with?(prog, comp.output)
      recurse_result = find_a(prog, possible_a)
      if recurse_result
        return recurse_result
      else
        # no match on recursion
      end
    else
      # the output didn't match
    end
  end

  nil
end

def ends_with?(prog, output)
  prog.reverse.zip(output.reverse).all? do |expected, actual|
    actual.nil? || expected == actual
  end
end

AOC.part2 do
  base = Computer.new(input)
  find_a(base.prog, 0)
end
