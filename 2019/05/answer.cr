require "../intcode"

input = File.read("input.txt").chomp

program = Intcode.new(input, [1])
program.run
puts program.output
