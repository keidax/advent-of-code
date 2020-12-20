class Tile
  property id : Int32
  property data : Array(Array(Bool))

  @edges : Array(UInt16)?

  def initialize(@id, @data)
  end

  def edges : Array(UInt16)
    @edges ||= begin
      rotated = data.transpose

      [
        edge(data.first),
        edge(data.last),
        edge(rotated.first),
        edge(rotated.last),
      ]
    end
  end

  def top_edge(flip = false)
    edge(data.first, flip)
  end

  def bottom_edge(flip = false)
    edge(data.last, flip)
  end

  def left_edge(flip = false)
    edge(data.map(&.first), flip)
  end

  def right_edge(flip = false)
    edge(data.map(&.last), flip)
  end

  def each_orientation(&blk : Tile ->)
    tile = self

    4.times do
      yield tile
      tile = tile.rotate
    end

    tile = tile.flip

    4.times do
      yield tile
      tile = tile.rotate
    end
  end

  def find_orientation(&blk : Tile -> Bool) : Tile?
    each_orientation do |tile|
      return tile if yield tile
    end

    nil
  end

  # Rotate the tile image clockwise
  def rotate : Tile
    Tile.new(id, data.reverse.transpose)
  end

  # Flip the tile vertically
  def flip : Tile
    Tile.new(id, data.reverse)
  end

  # Generate a unique signature for each edge by translating it
  # into binary. Since the image may be flipped, choose the smaller
  # signature.
  private def edge(bools : Array(Bool), flip = true) : UInt16
    forward = 0_u16
    reverse = 0_u16

    bools.each_with_index do |b, i|
      if b
        forward |= 1 << i
        reverse |= 1 << (bools.size - i - 1)
      end
    end

    if flip
      Math.min(forward, reverse)
    else
      forward
    end
  end
end

tile_data = File.read_lines("input.txt")
  .chunks(&.blank?)
  .reject! { |blank, _| blank }
  .map { |_, lines| lines }

tiles = tile_data.map do |tile_lines|
  tile_lines[0].match /Tile (\d+):/
  id = $1.to_i

  image = tile_lines[1..].map do |line|
    line.chars.map { |c| c == '#' }
  end
  Tile.new(id, image)
end

# Part 1
edge_counts = Hash(UInt16, Int32).new

tiles.each do |tile|
  tile.edges.each do |edge|
    edge_counts[edge] ||= 0
    edge_counts[edge] += 1
  end
end

edge_tiles = tiles.select do |tile|
  2 == tile.edges.count do |edge|
    edge_counts[edge] == 1
  end
end

puts edge_tiles.map(&.id.to_i64).product

# Part 2

SIZE = 12

grid = Array(Array(Tile?)).new(12) { Array(Tile?).new(12) { nil } }

# Find the first corner
corner = edge_tiles.first
corner_edges = corner.edges.select { |edge| edge_counts[edge] == 1 }.sort

# Orient the corner so the correct edges are facing out
corner.each_orientation do |_corner|
  if [_corner.top_edge(flip: true), _corner.left_edge(flip: true)].sort == corner_edges
    corner = _corner
    break
  end
end

grid[0][0] = corner

# Fill in the rest of the top row of the grid
(1...SIZE).each do |i|
  prev_edge = grid[0][i - 1].not_nil!.right_edge

  next_tile = nil
  tiles.each do |tile|
    if (
         next_tile = tile.find_orientation do |tile|
           tile.left_edge == prev_edge
         end
       )
      break
    end
  end

  grid[0][i] = next_tile
end

puts grid[0].count &.itself

# Fill in remaining rows
(1...SIZE).each do |row|
  (0...SIZE).each do |col|
    prev_edge = grid[row - 1][col].not_nil!.bottom_edge

    next_tile = nil

    tiles.each do |tile|
      next_tile = tile.find_orientation { |t| t.top_edge == prev_edge }
      break if next_tile
    end

    grid[row][col] = next_tile
  end
  puts grid[row].count &.itself
end
