require "../intcode"

input = File.read("input.txt")
program = Intcode.new(input)
program.run

loop do
  ch = program.output.receive.chr
  print ch
  break if ch == '\n'
end

# (!A || !B || !C) && D && (((I || F) && E) || H)
spring_logic = <<-BOT
NOT A T
NOT B J
OR T J
NOT C T
OR T J
AND D J
NOT D T
OR I T
OR F T
AND E T
OR H T
AND T J
RUN

BOT

logic_input = spring_logic.chars.map &.ord.to_i64
logic_input.each do |byte|
  program.input.send byte
end

loop do
  ch = program.output.receive

  if ch <= 127
    print ch.chr
  else
    puts ch
    exit 0
  end
rescue Channel::ClosedError
  break
end
