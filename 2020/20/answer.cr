class Tile
  property id : Int32
  property data : Array(Array(Bool))

  @edges : Array(UInt16)?

  def initialize(@id, @data)
  end

  def trimmed_data
    data[1..-2].map { |row| row[1..-2] }
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

TILE_SIZE = 8

def fill_grid(tiles, corners, edge_counts) : Array(Array(Tile))
  grid_size = Math.sqrt(tiles.size).to_i

  # Find the first corner
  corner = corners.first
  corner_edges = corner.edges.select { |edge| edge_counts[edge] == 1 }.sort
  tiles.delete(corner)

  # Orient the corner so the correct edges are facing out
  corner = corner.find_orientation do |corner|
    [corner.top_edge(flip: true), corner.left_edge(flip: true)].sort == corner_edges
  end.not_nil!

  grid = Array(Array(Tile)).new
  grid << [corner] of Tile

  # Fill in the rest of the top row of the grid
  (1...grid_size).each do |i|
    prev_edge = grid[0][i - 1].right_edge

    next_tile = nil
    tiles.each do |tile|
      next_tile = tile.find_orientation { |t| t.left_edge == prev_edge }
      if next_tile
        tiles.delete(tile)
        break
      end
    end

    grid[0] << next_tile.not_nil!
  end

  # Fill in remaining rows
  (1...grid_size).each do |row|
    grid << [] of Tile
    (0...grid_size).each do |col|
      prev_edge = grid[row - 1][col].bottom_edge

      next_tile = nil

      tiles.each do |tile|
        next_tile = tile.find_orientation { |t| t.top_edge == prev_edge }
        if next_tile
          tiles.delete(tile)
          break
        end
      end

      grid[row] << next_tile.not_nil!
    end
  end

  grid
end

grid = fill_grid(tiles, edge_tiles, edge_counts)

image_data = Array.new(TILE_SIZE * grid.size) { Array(Bool).new(TILE_SIZE * grid.size) { false } }
grid.each_with_index do |row, i|
  row.each_with_index do |tile, j|
    tile.trimmed_data.each_with_index do |data_row, y|
      data_row.each_with_index do |pixel, x|
        image_data[i*TILE_SIZE + y][j*TILE_SIZE + x] = pixel
      end
    end
  end
end

sea_monster_data = <<-EOF
                  # 
#    ##    ##    ###
 #  #  #  #  #  #   
EOF

sea_monster_points = [] of {Int32, Int32}
sea_monster_data.lines.map_with_index do |line, y|
  line.chars.map_with_index do |c, x|
    if c == '#'
      sea_monster_points << {y, x}
    end
  end
end

def find_sea_monsters(grid, points)
  locations = [] of {Int32, Int32}

  grid.each_with_index do |row, y|
    out_of_bounds = false

    row.each_with_index do |col, x|
      found = true
      points.each do |j, i|
        if y + j >= grid.size
          found = false
          out_of_bounds = true
          break
        end
        if x + i >= row.size
          found = false
          out_of_bounds = true
          break
        end
        unless grid[y + j][x + i]
          found = false
          break
        end
      end

      break if out_of_bounds

      if found
        locations << {y, x}
      end
    end
  end

  locations
end

image = Tile.new(0, image_data)
sea_monsters = [] of {Int32, Int32}

image.each_orientation do |flipped_image|
  sea_monsters = find_sea_monsters(flipped_image.data, sea_monster_points)
  if sea_monsters.any?
    image = flipped_image
    break
  end
end

total_sm_pixels = sea_monsters.size * sea_monster_points.size
total_filled_pixels = image.data.sum &.count(&.itself)

puts total_filled_pixels - total_sm_pixels
