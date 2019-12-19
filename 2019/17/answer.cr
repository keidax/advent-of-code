require "../intcode"

input = File.read("./input.txt").chomp

program = Intcode.new(input)
program.run

scaffold = Array.new(33) { Array(Char).new(37) { ' ' } }

row = 0
col = 0
loop do
  ch = program.output.receive.chr
  print ch

  case ch
  when '#', '.'
    scaffold[row][col] = ch
    col += 1
  when '^', 'v', '<', '>'
    scaffold[row][col] = '#'
    col += 1
  when '\n'
    row += 1
    col = 0
  else
    raise "unknown char: #{ch}"
  end
rescue Channel::ClosedError
  break
end

sum = 0

(1...(scaffold.size - 1)).each do |row|
  (1...(scaffold.first.size - 1)).each do |col|
    # Find an intersection
    if [
         scaffold[row][col],
         scaffold[row][col + 1],
         scaffold[row + 1][col],
         scaffold[row][col - 1],
         scaffold[row - 1][col],
       ].all? &.==('#')
      sum += row*col
    end
  end
end

puts sum
