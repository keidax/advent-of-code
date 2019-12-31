require "../intcode"

input = File.read("input.txt").chomp

def run_combination(prog_input, comb : Array(Int64)) : Int64
  last_out = Channel(Int64).new(1)
  last_out.send(0)

  comb.each do |i|
    prog = Intcode.new(prog_input, [i, last_out.receive] of Int64)
    prog.run
    last_out = prog.output
  end

  last_out.receive
end

combinations = (0_i64...5_i64).to_a.permutations

signals = combinations.map do |combo|
  signal_out = run_combination(input, combo)
  {combo, signal_out}
end

puts signals.max_by { |(combo, signal_out)| signal_out }
