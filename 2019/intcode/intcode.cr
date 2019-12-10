require "./*"

class Intcode
  @program : Array(Int64)
  getter input : Channel(Int64)
  getter output = Channel(Int64).new(5)
  getter relative_base = 0

  property verbose = false

  delegate :<<, to: @output
  delegate :[], :[]=, to: @program

  def initialize(@program, @input)
  end

  def initialize(program : String)
    initialize(program, Channel(Int64).new(5))
  end

  def initialize(program : String, input : Array(Int64))
    input_chan = Channel(Int64).new(input.size)
    input.each { |i| input_chan.send(i) }
    initialize(program, input_chan)
  end

  def initialize(program : String, @input : Channel(Int64))
    parsed_input = program.split(',').map &.to_i64
    # Add extra capacity to the program
    @program = parsed_input.concat(Array.new(10000) { 0_i64 })
  end

  def initialize(program : String, @input : Channel(Int64), @output : Channel(Int64))
    initialize(program, @input)
  end

  def run
    spawn do
      pointer = 0_i64

      while pointer
        instruction = Instruction.new(self, pointer)

        result = instruction.run
        pointer = modify_pointer(pointer, result)
      end

      output.close
    end
  end

  def modify_pointer(pointer, result) : Int64?
    if result[:jmp] < 0
      nil
    elsif result[:adv] > 0
      pointer + result[:adv]
    else
      result[:jmp]
    end
  end

  def adjust_relative_base(offset)
    @relative_base += offset
  end

  def log(str : String)
    puts str if @verbose
  end
end
