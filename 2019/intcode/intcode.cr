require "./*"

class Intcode
  @program : Array(Int32)
  getter input : Channel(Int32)

  getter output = Channel(Int32).new(5)

  delegate :<<, to: @output
  delegate :[], :[]=, size, to: @program

  def initialize(@program, @input)
  end

  def initialize(program : String)
    initialize(program, Channel(Int32).new(5))
  end

  def initialize(program : String, input : Array(Int32))
    input_chan = Channel(Int32).new(input.size)
    input.each { |i| input_chan.send(i) }
    initialize(program, input_chan)
  end

  def initialize(program : String, @input : Channel(Int32))
    @program = program.split(',').map &.to_i
  end

  def initialize(program : String, @input : Channel(Int32), @output : Channel(Int32))
    initialize(program, @input)
  end

  def run
    spawn do
      pointer = 0

      while pointer
        instruction = Instruction.new(self, pointer)

        result = instruction.run
        pointer = modify_pointer(pointer, result)
      end
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
