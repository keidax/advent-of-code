require "../intcode"

program = File.read("input.txt").chomp
computers = Array(Intcode).new(initial_capacity: 50)

50.times do |i|
  computer = Intcode.new(program, [i.to_i64])
  computer.default_input = -1
  computer.run

  computers << computer
end

loop do
  addr, x, y = nil, nil, nil
  {% if true %}
  select
    {% for i in (0...50) %}
    when addr = computers[{{i}}].output.receive
      x, y = computers[{{i}}].output.receive, computers[{{i}}].output.receive
    {% end %}
  end
  {% end %}
  if addr == 255
    puts "#{x}, #{y}"
    break
  else
    input = computers[addr].input
    input.send x
    input.send y
  end
end
