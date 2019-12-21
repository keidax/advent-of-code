require "../intcode"

input = File.read("./input.txt").chomp

done = Channel(Int64).new(50)

(0_i64...50_i64).each do |x|
  (0_i64...50_i64).each do |y|
    spawn do
      bot_program = Intcode.new(input, [x, y])
      bot_program.run
      done.send(bot_program.output.receive)
    end
  end
  Fiber.yield
end

pulled = 0
2500.times do
  pulled += done.receive
end

puts pulled
