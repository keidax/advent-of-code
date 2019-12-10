require "../intcode"

input = File.read("input.txt").chomp

prog = Intcode.new(input, [1_i64])
prog.run

Fiber.yield

while output = prog.output.receive?
  puts output
end
