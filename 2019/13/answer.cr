require "../intcode"

input = File.read("input.txt").chomp

prog = Intcode.new(input)
out = prog.output

enum Tile
  Empty  = 0
  Wall
  Block
  Paddle
  Ball
end

screen = Array.new(100) { Array.new(100) { Tile::Empty } }

prog.run

loop do
  x, y, id = out.receive, out.receive, out.receive
  screen[y][x] = Tile.new(id.to_i32)

  break if out.closed?
end

puts screen.sum { |row| row.count { |tile| tile == Tile::Block } }
