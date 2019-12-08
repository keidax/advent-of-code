enum Opcode
  Add       =  1
  Mult      =  2
  Input     =  3
  Output    =  4
  JumpTrue  =  5
  JumpFalse =  6
  LessThan  =  7
  Equal     =  8
  Exit      = 99

  def size : Int
    case self
    when Add, Mult, LessThan, Equal
      4
    when JumpTrue, JumpFalse
      3
    when Input, Output
      2
    when Exit
      1
    else
      raise "unknown size for #{self}"
    end
  end
end

enum ParamMode
  Position  = 0
  Immediate = 1
end

# Contains a relative offset to advance the pointer,
# or an absolute instruction number to jump to.
# If the jump is -1, program will exit
alias PointerResult = {adv: Int32, jmp: Int32}

class Instruction
  @opcode : Opcode
  @parameter_modes : Array(ParamMode)
  @data : Array(Int32)
  @position : Int32
  @program : Intcode

  delegate size, to: @opcode

  def initialize(@program, @position)
    instruction = @program[@position]
    @opcode = Opcode.new(instruction % 100)

    data_size = @opcode.size - 1

    format = "%0#{data_size}d"
    mode_str = format % (instruction // 100)
    modes = mode_str.each_char.map { |c| ParamMode.new(c.to_i) }
    @parameter_modes = modes.to_a.reverse # Reverse to match indexing

    @data = @program[@position + 1, data_size]
  end

  def [](index : Int) : Int
    val = @data[index]
    mode = @parameter_modes[index]

    case mode
    when ParamMode::Position
      @program[val]
    when ParamMode::Immediate
      val
    else
      raise "unknown param mode #{mode}"
    end
  end

  def []=(index : Int, value) : Int
    mode = @parameter_modes[index]

    case mode
    when ParamMode::Position
      pos = @data[index]
      @program[pos] = value
    when ParamMode::Immediate
      raise "can't write to an immediate parameter"
    else
      raise "unknown param mode #{mode}"
    end
  end

  # Return pointer to the next in
  def run : PointerResult
    case @opcode
    when Opcode::Add
      puts "adding"
      self[2] = self[0] + self[1]
    when Opcode::Mult
      puts "multiplying"
      self[2] = self[0] * self[1]
    when Opcode::Input
      puts "getting input"
      self[0] = @program.input.receive
    when Opcode::Output
      puts "setting output #{self[0]}"
      @program.output.send(self[0])
    when Opcode::JumpTrue
      return {adv: 0, jmp: self[1]} if self[0] != 0
    when Opcode::JumpFalse
      return {adv: 0, jmp: self[1]} if self[0] == 0
    when Opcode::LessThan
      self[2] = if self[0] < self[1]
                  1
                else
                  0
                end
    when Opcode::Equal
      self[2] = if self[0] == self[1]
                  1
                else
                  0
                end
    when Opcode::Exit
      puts "exiting"
      return {adv: 0, jmp: -1}
    else
      raise "unknown opcode #{@opcode}"
    end

    # For most instructions, advance by the instruction size
    {adv: @opcode.size, jmp: 0}
  end
end
