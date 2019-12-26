require "../intcode"

program = File.read("input.txt").chomp
computers = Array(Intcode).new(initial_capacity: 50)

50.times do |i|
  # Make sure the queue is long enough to hold a bunch of packets
  input_queue = Channel(Int64).new(50)
  input_queue.send i.to_i64

  computer = Intcode.new(program, input_queue)
  computer.default_input = -1
  computer.run

  computers << computer
end

class NAT
  @computers : Array(Intcode)
  @current_value : {Int64, Int64}?
  @previous_value : {Int64, Int64}?

  def initialize(@computers)
  end

  def store(x, y)
    puts "Stored #{y} in NAT"
    @current_value = {x, y}
  end

  def check_idle
    idle_count = @computers.count &.idle?
    return unless @computers.size == idle_count

    if !@current_value
      puts "no value stored in the NAT!"
      return
    end

    cur_value = @current_value.not_nil!

    if @previous_value
      prev_value = @previous_value.not_nil!
      if cur_value[1] == prev_value[1]
        puts cur_value[1]
        exit 0
      end
    end

    input = @computers[0].input
    input.send cur_value[0]
    input.send cur_value[1]

    # Computer 0 needs a chance to run before we check idleness again
    sleep 0.1

    @previous_value = @current_value
  end
end

nat = NAT.new(computers)

loop do
  addr = nil

  i, addr = Channel.non_blocking_select(computers.map &.output.receive_select_action)

  unless addr.is_a?(Int64)
    Fiber.yield
    nat.check_idle
    next
  end

  x, y = computers[i].output.receive, computers[i].output.receive

  if addr == 255
    nat.store(x, y)
  elsif addr
    input = computers[addr].input
    input.send x
    input.send y
  end
end
