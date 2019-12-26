enum Opcode
  Add       =  1
  Mult      =  2
  Input     =  3
  Output    =  4
  JumpTrue  =  5
  JumpFalse =  6
  LessThan  =  7
  Equal     =  8
  RelBase   =  9
  Exit      = 99

  def size : Int
    case self
    when Add, Mult, LessThan, Equal
      4
    when JumpTrue, JumpFalse
      3
    when Input, Output, RelBase
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
  Relative  = 2
end

# Contains a relative offset to advance the pointer,
# or an absolute instruction number to jump to.
# If the jump is -1, program will exit
alias PointerResult = {adv: Int64, jmp: Int64}

class Instruction
  @opcode : Opcode
  @parameter_modes : Array(ParamMode)
  @data : Array(Int64)
  @position : Int64
  @program : Intcode

  delegate size, to: @opcode
  delegate log, to: @program

  def initialize(@program, @position)
    instruction = @program[@position]
    @opcode = Opcode.new((instruction % 100).to_i32)

    data_size = @opcode.size - 1

    format = "%0#{data_size}d"
    mode_str = format % (instruction // 100)
    modes = mode_str.each_char.map { |c| ParamMode.new(c.to_i) }
    @parameter_modes = modes.to_a.reverse # Reverse to match indexing

    @data = @program[@position + 1, data_size]
  end

  def [](index : Int64) : Int64
    val = @data[index]
    mode = @parameter_modes[index]

    case mode
    when ParamMode::Position
      log "    pos #{val} : #{@program[val]}"
      @program[val]
    when ParamMode::Immediate
      log "    imm : #{val}"
      val
    when ParamMode::Relative
      log "    rel #{val} : #{@program[@program.relative_base + val]}"
      @program[@program.relative_base + val]
    else
      raise "unknown param mode #{mode}"
    end
  end

  def []=(index : Int64, value : Int64) : Int64
    mode = @parameter_modes[index]

    case mode
    when ParamMode::Position
      pos = @data[index]
      log "    pos #{pos} = #{value}"
      @program[pos] = value
    when ParamMode::Immediate
      raise "can't write to an immediate parameter"
    when ParamMode::Relative
      off = @data[index]
      log "    rel #{off} = #{value}"
      @program[@program.relative_base + off] = value
    else
      raise "unknown param mode #{mode}"
    end
  end

  # Return pointer to the next in
  def run : PointerResult
    case @opcode
    when Opcode::Add
      log "adding"
      self[2] = self[0] + self[1]
    when Opcode::Mult
      log "multiplying"
      self[2] = self[0] * self[1]
    when Opcode::Input
      log "getting input"
      if @program.default_input
        select
        when input = @program.input.receive
          @program.last_received_default = false
          self[0] = input
        else
          log "got default input"

          @program.last_received_default = true
          self[0] = @program.default_input.not_nil!

          # If looping on default input, we should yield the fiber
          Fiber.yield
        end
      else
        self[0] = @program.input.receive
      end
    when Opcode::Output
      log "setting output #{self[0]}"
      @program.last_received_default = false
      @program.output.send(self[0])
    when Opcode::JumpTrue
      log "jump if true"
      return {adv: 0_i64, jmp: self[1]} if self[0] != 0_i64
    when Opcode::JumpFalse
      log "jump if false"
      return {adv: 0_i64, jmp: self[1]} if self[0] == 0_i64
    when Opcode::LessThan
      log "setting less than"
      self[2] = if self[0] < self[1]
                  1_i64
                else
                  0_i64
                end
    when Opcode::Equal
      log "setting equal"
      self[2] = if self[0] == self[1]
                  1_i64
                else
                  0_i64
                end
    when Opcode::RelBase
      log "adjusting relative base by #{self[0]}"
      @program.adjust_relative_base(self[0])
    when Opcode::Exit
      log "exiting"
      return {adv: 0_i64, jmp: -1_i64}
    else
      raise "unknown opcode #{@opcode}"
    end

    # For most instructions, advance by the instruction size
    {adv: @opcode.size.to_i64, jmp: 0_i64}
  end
end
