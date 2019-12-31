require "../intcode"

input = File.read("input.txt").chomp

program = Intcode.new(input, [1_i64])
program.run

loop do
  output = program.output.receive
  puts output

  break unless output == 0
end
