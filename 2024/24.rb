require_relative "aoc"

class LogicSystem
  def initialize
    @values = {}
    @gates = {}

    @input_wires = Set.new
    @output_wires = []
  end

  def [](wire)
    @values.fetch(wire) do
      @values[wire] = @gates[wire].value
    end
  end

  def []=(wire, value)
    @values[wire] = value
  end

  def add_gate(gate, out_wire)
    @gates[out_wire] = gate
    gate.system = self

    @output_wires << out_wire if out_wire.start_with?("z")
  end

  def add_input(wire, value)
    @values[wire] = value
    @input_wires << wire
  end

  def max_bits
    @output_wires.max[1..].to_i
  end

  def reset
    @values.clear
    @input_wires.each { @values[_1] = 0 }
  end

  # output bits, from least to most significant
  def output_bits
    @output_wires.sort.map { @gates[_1].value }
  end

  def gates_for_output(output_wire, ignore)
    gates = []
    queue = [@gates[output_wire]]

    while queue.any?
      next_gate = queue.shift
      next if ignore.include?(next_gate)

      gates << next_gate

      unless @input_wires.include?(next_gate.in_wire1)
        queue << @gates[next_gate.in_wire1]
      end

      unless @input_wires.include?(next_gate.in_wire2)
        queue << @gates[next_gate.in_wire2]
      end
    end

    gates
  end

  def adder_works?(bit)
    min_bit = [bit - 3, 0].max

    reset

    (min_bit..bit).each do |test_bit|
      self[x(test_bit)] = 1
    end

    if (min_bit..bit).any? { |test_bit| self[z(test_bit)] != 1 }
      return false
    end

    reset

    self[x(bit)] = 1
    self[y(bit)] = 1

    if self[z(bit)] != 0 || self[z(bit).succ] != 1
      return false
    end

    reset

    (min_bit..bit).each do |test_bit|
      self[x(test_bit)] = 1
    end

    self[y(min_bit)] = 1

    if (min_bit..bit).any? { |test_bit| self[z(test_bit)] != 0 }
      return false
    end

    if self[z(bit).succ] != 1
      return false
    end

    true
  end

  def x(bit) = "x%02d" % bit

  def y(bit) = "y%02d" % bit

  def z(bit) = "z%02d" % bit

  def check_gates_for_bit(bit, already_checked)
    return if adder_works?(bit)

    other_output_bit = output_bits.rindex(1)
    raise "expected a more significant bit to be set: #{bit}, #{other_output_bit}" unless other_output_bit > bit

    bit_range = bit..other_output_bit
    possible_gates = Set.new

    bit_range.each do |out_bit|
      possible_gates.merge(gates_for_output(z(out_bit), already_checked))
    end

    possible_gates.to_a.combination(2) do |a, b|
      swap_gates(a, b)

      swapped_worked =
        begin
          bit_range.all? do |test_bit|
            adder_works?(test_bit)
          end
        rescue SystemStackError
          # In case there is now a loop in the gates
          false
        end

      return [a, b] if swapped_worked

      swap_gates(a, b)
    end

    raise "no combinations worked"
  end

  def swap_gates(a, b)
    @gates[a.out_wire] = b
    @gates[b.out_wire] = a

    a.out_wire, b.out_wire = b.out_wire, a.out_wire
  end

  # General strategy:
  # Iterate from the lowest to highest bits of the adder. For each set of input and output bits,
  # make sure the inputs control the output as expected. Mark the gates related to that set of bits
  # as "good". If there's a deviation, gather all the gates for the deviating bits, minus the "good"
  # set. Test every pair of gates within this group, swapping the gate outputs until the adder works
  # again.
  #
  # This strategy works for the given puzzle input. It's not a truly general solution, though,
  # because it assumes each pair of swapped gates doesn't overlap the range of another pair of
  # swapped gates.
  def repair!(max_gates)
    swapped_gates = []
    good_gates = Set.new

    (0...max_bits).each do |i|
      if (swapped = check_gates_for_bit(i, good_gates))
        swapped_gates.concat swapped
      end

      break if swapped_gates.size >= max_gates

      new_checked_gates = gates_for_output(z(i), good_gates)
      good_gates.merge(new_checked_gates)
    end

    swapped_gates
  end
end

class Gate
  attr_accessor :system

  attr_reader :in_wire1, :in_wire2
  attr_accessor :out_wire

  def initialize(in1, in2, out)
    @in_wire1 = in1
    @in_wire2 = in2
    @out_wire = out
  end

  def value = raise "implement in subclass"
end

class XorGate < Gate
  def value = system[@in_wire1] ^ system[@in_wire2]
end

class OrGate < Gate
  def value = system[@in_wire1] | system[@in_wire2]
end

class AndGate < Gate
  def value = system[@in_wire1] & system[@in_wire2]
end

input = AOC.day(24)
system = LogicSystem.new

initial_value_input, gate_input = input.line_sections

initial_value_input.each do |line|
  raise "bad input" unless /(\w+): (\d)/ =~ line
  system.add_input($1, $2.to_i)
end

gate_input.each do |line|
  gate = case line
  when /(\w+) AND (\w+) -> (\w+)/
    AndGate.new($1, $2, $3)
  when /(\w+) OR (\w+) -> (\w+)/
    OrGate.new($1, $2, $3)
  when /(\w+) XOR (\w+) -> (\w+)/
    XorGate.new($1, $2, $3)
  end

  system.add_gate(gate, $3)
end

AOC.part1 do
  system.output_bits.reverse.join("").to_i(2)
end

system.reset
if system.output_bits.any?(1)
  raise "output is on at initial state"
end

AOC.part2 do
  swapped_gates = system.repair!(8)
  swapped_gates.map(&:out_wire).sort.join(",")
end
