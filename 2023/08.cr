require "./aoc"

AOC.day!(8)

# Translate L/R into tuple index 0/1
turns = AOC.lines[0].chars.map { |c| c == 'L' ? 0 : 1 }

nodes = {} of String => {String, String}

AOC.lines[2..].each do |line|
  md = line.match!(/(...) = \((...), (...)\)/)

  nodes[md[1]] = {md[2], md[3]}
end

def count_steps(turns, nodes)
  elem = "AAA"
  count = 0

  turns.cycle do |t|
    count += 1
    elem = nodes[elem][t]

    break if elem == "ZZZ"
  end

  count
end

def find_z_node(turns, nodes, start_node) : Int64
  steps = 0i64
  elem = start_node

  while true
    turns.each do |t|
      steps += 1
      elem = nodes[elem][t]

      if elem.ends_with?('Z')
        return steps
      end
    end
  end
end

def is_cycle?(turns, nodes, start_node, cycle_size)
  elem = start_node

  turns = turns.cycle

  cycle_size.times do
    elem = nodes[elem][turns.next.as(Int32)]
  end

  end_elem = elem
  raise "expected #{end_elem} to end with Z" unless end_elem.ends_with? 'Z'

  cycle_size.times do
    elem = nodes[elem][turns.next.as(Int32)]
  end

  raise "expected #{elem} to be #{end_elem}" unless end_elem == elem
  true
end

AOC.part1 do
  count_steps(turns, nodes)
end

AOC.part2 do
  start_nodes = nodes.keys.select { |k| k.ends_with?("A") }

  # This takes advantage of several properties of the input:
  # - Following the steps from every start node will lead to exactly one end node before
  #   looping around. E.g. AAA -> ZZZ can be considered a distinct cycle from any of the
  #   other start/end positions.
  # - The end node is always reached exactly at the end of one iteration through the step
  #   instructions. This makes a consistent cycle. If the cycle wasn't cleanly divisible
  #   by the instruction count, then it might not be a consistent size.
  # - Reaching the end node for the first time takes the same number of steps as reaching
  #   the end node for every subsequent time. The first time through the cycle is not
  #   longer or shorter. In other words, we don't need to run through the input for a
  #   while to find a stable cycle.

  cycles = start_nodes.map do |start|
    find_z_node(turns, nodes, start)
  end

  # This provides runtime verification of the properties described above
  unless start_nodes.zip(cycles).all? { |start_node, cycle_size|
           is_cycle?(turns, nodes, start_node, cycle_size)
         }
    raise "some results were not cycles"
  end

  # Once we know all cycle sizes, the answer is as simple as finding the LCM of all
  # of them
  cycles.reduce { |a, b| a.lcm(b) }
end
