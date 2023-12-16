require "./aoc"

AOC.day!(16)

enum Direction
  Right
  Down
  Left
  Up

  def forward(row, col)
    case self
    in .right? then {self, row, col + 1}
    in .left?  then {self, row, col - 1}
    in .up?    then {self, row - 1, col}
    in .down?  then {self, row + 1, col}
    end
  end

  def turn_right(row, col)
    case self
    in .right? then {Down, row + 1, col}
    in .left?  then {Up, row - 1, col}
    in .up?    then {Right, row, col + 1}
    in .down?  then {Left, row, col - 1}
    end
  end

  def turn_left(row, col)
    case self
    in .right? then {Up, row - 1, col}
    in .left?  then {Down, row + 1, col}
    in .up?    then {Left, row, col - 1}
    in .down?  then {Right, row, col + 1}
    end
  end
end

alias BeamTile = {Direction, Int32, Int32}

class BeamVisitor
  getter next_tiles = Deque(BeamTile).new
  getter visited = Set(BeamTile).new
  getter field : Array(Array(Char))

  def initialize(@field)
  end

  def visit(start : BeamTile)
    _visit(start)

    until next_tiles.empty?
      _visit(next_tiles.shift)
    end
  end

  def reset!
    visited.clear
    next_tiles.clear
  end

  private def _visit(beam_tile : BeamTile)
    direction, row, col = beam_tile

    return if row < 0 || col < 0
    return if row >= field.size || col >= field[row].size

    # Bail if we've already visited this tile from this direction
    return if !visited.add?(beam_tile)

    tile = field[row][col]

    case {tile, direction}
    when {'.', _},
         {'-', .right?},
         {'-', .left?},
         {'|', .up?},
         {'|', .down?}
      straight = direction.forward(row, col)
      next_tiles << straight
    when {'-', .up?},
         {'-', .down?},
         {'|', .left?},
         {'|', .right?}
      split_right = direction.turn_right(row, col)
      split_left = direction.turn_left(row, col)

      next_tiles << split_right
      next_tiles << split_left
    when {'/', .up?},
         {'/', .down?},
         {'\\', .left?},
         {'\\', .right?}
      right = direction.turn_right(row, col)
      next_tiles << right
    when {'/', .left?},
         {'/', .right?},
         {'\\', .up?},
         {'\\', .down?}
      left = direction.turn_left(row, col)
      next_tiles << left
    else
      raise "missing instructions for '#{tile}' & #{direction}"
    end
  end

  def energize_count
    visited.map { |(_beam, row, col)| {row, col} }.to_set.size
  end
end

cave = AOC.lines.map(&.chars)

AOC.part1 do
  visitor = BeamVisitor.new(cave)
  visitor.visit({Direction::Right, 0, 0})
  visitor.energize_count
end

FIBER_COUNT = 4

AOC.part2 do
  entry_count = (cave.size * 2) + (cave[0].size * 2)
  entry_chan = Channel(BeamTile).new(entry_count)

  (0...cave.size).each do |row|
    entry_chan.send({Direction::Right, row, 0})
    entry_chan.send({Direction::Left, row, cave[row].size - 1})
  end

  (0...cave[0].size).each do |col|
    entry_chan.send({Direction::Down, 0, col})
    entry_chan.send({Direction::Up, cave.size - 1, col})
  end

  entry_chan.close
  energize_chan = Channel(Int32).new(entry_count)

  FIBER_COUNT.times do
    spawn do
      visitor = BeamVisitor.new(cave)
      while (entry = entry_chan.receive?)
        visitor.visit(entry)
        energize_chan.send(visitor.energize_count)
        visitor.reset!
      end
    end
  end

  results = [] of Int32
  entry_count.times { results << energize_chan.receive }
  results.max
end
