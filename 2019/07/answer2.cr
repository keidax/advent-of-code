require "../intcode"

input = File.read("input.txt").chomp

def run_combination(prog_input, comb : Array(Int32)) : Int32
  first_in = last_out = Channel(Int32).new(2)

  programs = comb.map_with_index do |phase, i|
    if i + 1 < comb.size
      prog = Intcode.new(prog_input, last_out)
    else
      # Final amp -- loop back to the first one
      prog = Intcode.new(prog_input, last_out, first_in)
    end

    last_out.send(phase)
    # First amp -- seed with input 0
    last_out.send 0 if i == 0

    last_out = prog.output
    prog
  end

  programs.each &.run
  Fiber.yield

  last_out.receive
end

combinations = (5...10).to_a.permutations

signals = combinations.map do |combo|
  signal_out = run_combination(input, combo)
  {combo, signal_out}
end

puts signals.max_by { |(combo, signal_out)| signal_out }
