require "./*"

class Intcode
  @program : Array(Int32)
  @input : Array(Int32)

  getter output = [] of Int32

  delegate :<<, to: @output
  delegate :[], :[]=, size, to: @program

  def initialize(@program, @input)
  end

  def initialize(program : String, @input)
    @program = program.split(',').map &.to_i
  end

  def get_input : Int
    @input.shift
  end

  def run
    pointer = 0

    while pointer
      instruction = Instruction.new(self, pointer)

      result = instruction.run
      pointer = modify_pointer(pointer, result)
    end
  end

  def modify_pointer(pointer, result) : Int32?
    if result[:jmp] < 0
      nil
    elsif result[:jmp] > 0
      result[:jmp]
    else
      pointer + result[:adv]
    end
  end
end
