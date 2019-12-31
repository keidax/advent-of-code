require "../intcode"

input = File.read("input.txt").chomp

program = Intcode.new(input, [5_i64])
program.run
puts program.output.receive
