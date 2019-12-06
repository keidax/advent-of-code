require "../intcode"

input = File.read("input.txt").chomp

program = Intcode.new(input, [5])
program.run
puts program.output
