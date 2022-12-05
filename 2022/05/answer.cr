require "../aoc"

AOC.day!(5)

lines = AOC.lines

first_blank_idx = lines.index!("")
stack_input = lines[0...first_blank_idx]
moves_input = lines[(first_blank_idx + 1)..-1]

stack_numbers = stack_input[-1].strip.split(/\s+/).map(&.to_i)
stack_count = stack_numbers.last

stacks = Array(Array(Char)).new(stack_count) { Array(Char).new }

stack_input[0..-2].reverse.each do |stack_line|
  stack_idx = 0
  char_idx = 1
  while stack_idx < stack_count
    crate = stack_line[char_idx]

    unless crate == ' '
      stacks[stack_idx] << crate
    end

    stack_idx += 1
    char_idx += 4
  end
end

orig_stacks = stacks.clone

instructions = moves_input.map do |m|
  md = m.match(/move (\d+) from (\d+) to (\d+)/).not_nil!
  {count: md[1].to_i, from: md[2].to_i - 1, to: md[3].to_i - 1}
end

def run_part1(stacks, count, from, to)
  (1..count).each do
    stacks[to] << stacks[from].pop
  end
end

def run_part2(stacks, count, from, to)
  stacks[to].concat(stacks[from].pop(count))
end

AOC.part1 do
  instructions.each { |inst| run_part1(stacks, **inst) }
  stacks.map(&.last).join("")
end

stacks = orig_stacks.clone

AOC.part2 do
  instructions.each { |inst| run_part2(stacks, **inst) }
  stacks.map(&.last).join("")
end
