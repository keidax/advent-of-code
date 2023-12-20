require "./aoc"

AOC.day!(20)

enum Pulse
  HIGH
  LOW
end

alias PulseSignal = {source: String, pulse: Pulse, destination: String}

abstract class PulseModule
  getter name : String
  getter destinations : Array(String)
  @pulse_queue : Deque(PulseSignal)

  def self.build(line, queue) : self
    klass = if line.starts_with?('&')
              Conjunction
            elsif line.starts_with?('%')
              FlipFlop
            elsif line.starts_with?("broadcaster")
              Broadcast
            else
              raise "not a valid module: #{line}"
            end

    line.match!(/(\w+) -> (.+)/)
    name = $~[1]
    destinations = $~[2].split(", ")

    klass.new(name, destinations, queue)
  end

  def initialize(@name, @destinations, @pulse_queue)
  end

  def send(pulse : Pulse)
    @destinations.each do |dest|
      @pulse_queue << {source: name, destination: dest, pulse: pulse}
    end
  end

  abstract def receive(signal : PulseSignal)
end

class Broadcast < PulseModule
  def receive(signal : PulseSignal)
    send(signal[:pulse])
  end
end

class FlipFlop < PulseModule
  @on = false

  def receive(signal : PulseSignal)
    return if signal[:pulse].high?

    if @on
      @on = false
      send(Pulse::LOW)
    else
      @on = true
      send(Pulse::HIGH)
    end
  end
end

class Conjunction < PulseModule
  getter memory = {} of String => Pulse
  getter got_hi = Set(String).new

  def update_inputs(inputs : Enumerable(String))
    inputs.each do |input|
      @memory[input] = Pulse::LOW
    end
  end

  def receive(signal : PulseSignal)
    @memory[signal[:source]] = signal[:pulse]

    if signal[:pulse].high?
      @got_hi << signal[:source]
    end

    if @memory.all? { |_, v| v.high? }
      send(Pulse::LOW)
    else
      send(Pulse::HIGH)
    end
  end
end

class Output < PulseModule
  def receive(signal : PulseSignal)
  end
end

class PulseCounter
  @queue = Deque(PulseSignal).new

  getter modules = {} of String => PulseModule
  delegate :[], to: @modules

  getter hi_counter = 0i64
  getter lo_counter = 0i64
  getter push_counter = 0i64

  def initialize(lines)
    lines.each do |line|
      new_mod = PulseModule.build(line, @queue)
      @modules[new_mod.name] = new_mod
    end

    @modules.values.select(&.is_a?(Conjunction)).each do |conj|
      conj_inputs = @modules.values.select do |mod|
        mod.destinations.includes?(conj.name)
      end.map(&.name)

      conj.as(Conjunction).update_inputs(conj_inputs)
    end

    outputs = (@modules.values.flat_map(&.destinations).uniq - @modules.keys)
    outputs.each do |output|
      @modules[output] = Output.new(output, [] of String, @queue)
    end
  end

  def handle_pulses
    until @queue.empty?
      next_pulse = @queue.shift

      if next_pulse[:pulse].high?
        @hi_counter += 1
      else
        @lo_counter += 1
      end

      @modules[next_pulse[:destination]].receive(next_pulse)
    end
  end

  def push_button
    @push_counter += 1

    button_pulse = {source: "button", destination: "broadcaster", pulse: Pulse::LOW}
    @queue << button_pulse

    handle_pulses
  end
end

AOC.part1 do
  counter = PulseCounter.new(AOC.lines)
  1000.times { counter.push_button }

  counter.hi_counter * counter.lo_counter
end

AOC.part2 do
  # This solution is based on the particular structure of the input. `broadcaster` sends
  # signals to several independent subgroups of modules. Each subgroup ultimately has an
  # output leading to one shared conjunction module, whose only output is `rx`. In our
  # particular input, this conjuction module is named `df`.
  #
  # For `rx` to receive a low pulse, every subgroup must send a high pulse to `df`. Since
  # each subgroup is independent, we assume they operate on a cycle. In other words, after
  # every N button pushes, each subgroup will send a high pulse to `df`, with N being
  # different per subgroup.
  #
  # Once we find the cycle size of each subgroup, then the answer is the least common
  # multiple of all cycles. This is the button push when every subgroup will send a high
  # pulse to `df` at the same time.

  counter = PulseCounter.new(AOC.lines)

  rx_input = counter.modules.values.find { |mod| mod.destinations.includes?("rx") }.as(Conjunction)

  rx_input_cycles : Hash(String, Int64?) = rx_input.memory.keys.to_h { |k| {k, nil.as(Int64?)} }

  loop do
    counter.push_button

    hi_list = rx_input.got_hi

    if hi_list.size > 0
      hi_list.each do |input_name|
        rx_input_cycles[input_name] ||= counter.push_counter
      end
      hi_list.clear

      if rx_input_cycles.all? { |k, v| v }
        break
      end
    end
  end

  rx_input_cycles.values.compact.reduce { |acc, i| acc.lcm(i) }
end
