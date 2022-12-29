require "../aoc"

AOC.day!(22)

enum Facing
  Right = 0
  Down  = 1
  Left  = 2
  Up    = 3

  def row_offset
    case self
    in Right, Left then 0
    in Up          then -1
    in Down        then 1
    end
  end

  def column_offset
    case self
    in Up, Down then 0
    in Right    then 1
    in Left     then -1
    end
  end

  def turn_left
    case self
    in Right then Up
    in Down  then Right
    in Left  then Down
    in Up    then Left
    end
  end

  def turn_right
    case self
    in Right then Down
    in Down  then Left
    in Left  then Up
    in Up    then Right
    end
  end
end

class Tile
  property row : Int32, column : Int32

  property? open : Bool

  def initialize(@row, @column, @open)
  end
end

class CubeFace
  property size : Int32
  property tiles : Array(Array(Tile))
  property edge_map = {} of Facing => CubeEdge

  def initialize(@size, grid, row, column)
    @tiles = Array(Array(Tile)).new

    (row...(row + size)).each do |y|
      tile_row = Array(Tile).new

      (column...(column + size)).each do |x|
        tile_row << grid[y][x].not_nil!
      end

      tiles << tile_row
    end
  end
end

class CubeEdge
  property from : CubeFace, to : CubeFace
  property rotations : Int32

  def initialize(@from, @to, @rotations)
  end
end

def next_tile_linear(grid, tile, facing)
  row = tile.row - 1
  column = tile.column - 1

  loop do
    row += facing.row_offset
    column += facing.column_offset

    row %= grid.size
    column %= grid[row].size

    if (next_tile = grid[row][column])
      return next_tile
    end
  end
end

def follow_path_linear(grid, path)
  tile = grid.first.compact.first
  facing = Facing::Right

  path.each do |step|
    case step
    when 'L'
      facing = facing.turn_left
    when 'R'
      facing = facing.turn_right
    when Int
      step.times do
        next_tile = next_tile_linear(grid, tile, facing)

        if next_tile.open?
          tile = next_tile
        else
          break
        end
      end
    end
  end

  return tile, facing
end

def stitch_edges(faces)
  faces.each do |face|
    Facing.values.each do |facing|
      # this link is already done
      next if face.edge_map[facing]?

      stitch_left_corner(faces, face, facing)
    end
  end
end

# Consider the following diagram:
#  +-----+
#  |     |
#  |face |
#  |  3  |
#  |     |
#  |    ^|
#  +----^+-----+
#  |    .|     |
#  |face.|face |
#  |  2 .<< 1  |
#  |     |     |
#  |     |     |
#  +-----+-----+
# Assume that edges between faces 1 & 2, and faces 2 & 3, have been
# established. This method will try to add the missing edge to
# complete the cube.
#
# From face 1, our target direction is up. So we turn left once,
# travel forward to face 2. Then we turn right, and travel in the
# original direction once more. If we've reached another face, we can
# establish an edge between this and the original face.
#
# Repeated application of this method for all combinations of faces
# and directions will eventually find all edges for the cube.

def stitch_left_corner(faces, face, facing)
  rotations = 1
  stitch_direction = facing.turn_left

  edge1 = face.edge_map[stitch_direction]?
  return unless edge1

  rotations += edge1.rotations
  edge1.rotations.times do
    stitch_direction = stitch_direction.turn_left
  end

  stitch_direction = stitch_direction.turn_right
  face2 = edge1.to
  edge2 = face2.edge_map[stitch_direction]?
  return unless edge2

  rotations += edge2.rotations
  edge2.rotations.times do
    stitch_direction = stitch_direction.turn_left
  end

  face3 = edge2.to
  face.edge_map[facing] = CubeEdge.new(face, face3, rotations)

  # one extra turn_left here to reverse the turn_right above
  opposite_facing = stitch_direction.turn_left.turn_left.turn_left

  if face3.edge_map[opposite_facing]?
    raise "other face already has this edge!"
  end

  opposite_rotations = (4 - rotations) % 4

  face3.edge_map[opposite_facing] = CubeEdge.new(face3, face, opposite_rotations)
end

def check_all_edges(faces)
  faces.each do |face|
    Facing.values.each do |direction|
      edge = face.edge_map[direction]
      other_face = edge.to

      raise "1" if face == other_face

      rotated_dir = direction
      edge.rotations.times { rotated_dir = rotated_dir.turn_left }

      opposite_dir = rotated_dir.turn_left.turn_left
      reverse_edge = other_face.edge_map[opposite_dir]

      raise "2" if reverse_edge.to != face

      reverse_edge.rotations.times { rotated_dir = rotated_dir.turn_left }
      raise "3" if rotated_dir != direction
    end
  end
end

def next_tile_cube(face, tile, facing)
  row = (tile.row - 1) % GRID_SIZE + facing.row_offset
  column = (tile.column - 1) % GRID_SIZE + facing.column_offset

  if (0 <= row < GRID_SIZE) && (0 <= column < GRID_SIZE)
    return face, face.tiles[row][column], facing
  end

  cross_edge(face.edge_map[facing], facing, row, column)
end

def cross_edge(edge, facing, row, column)
  edge.rotations.times do
    row, column = rotate_coordinates_left(row, column)
    facing = facing.turn_left
  end

  face = edge.to
  row %= GRID_SIZE
  column %= GRID_SIZE
  tile = face.tiles[row][column]

  return face, tile, facing
end

def rotate_coordinates_left(row, column)
  return (GRID_SIZE - 1 - column), row
end

def follow_path_cube(faces, path)
  face = faces.first
  tile = face.tiles.flatten.first
  facing = Facing::Right

  path.each do |step|
    case step
    when 'L'
      facing = facing.turn_left
    when 'R'
      facing = facing.turn_right
    when Int
      step.times do
        next_face, next_tile, next_facing = next_tile_cube(face, tile, facing)

        if next_tile.open?
          face = next_face
          tile = next_tile
          facing = next_facing
        else
          break
        end
      end
    end
  end

  return tile, facing
end

map_lines = AOC.lines[0..-3].map(&.chars)
path_line = AOC.lines.last

width = map_lines.map(&.size).max
height = map_lines.size
grid = Array(Array(Tile?)).new(height) { Array(Tile?).new(width, nil) }

(0...height).each do |row|
  (0...map_lines[row].size).each do |column|
    tile = case map_lines[row][column]
           when '.'
             Tile.new(row + 1, column + 1, open: true)
           when '#'
             Tile.new(row + 1, column + 1, open: false)
           else
             nil
           end

    grid[row][column] = tile
  end
end

path = path_line.chars.chunk(&.number?).map do |numeric, chars|
  if numeric
    chars.join.to_i
  else
    chars[0]
  end
end.to_a

AOC.part1 do
  tile, facing = follow_path_linear(grid, path)

  1000 * tile.row + 4 * tile.column + facing.value
end

GRID_SIZE = 50
# GRID_SIZE = 4 # for sample input

cube_map = Array(Array(CubeFace?)).new

(0...(grid.size)).step(by: GRID_SIZE) do |row|
  cube_row = [] of CubeFace?

  (0...(grid[row].size)).step(by: GRID_SIZE) do |column|
    cube_row << if grid[row][column]
      CubeFace.new(GRID_SIZE, grid, row, column)
    else
      nil
    end
  end

  cube_map << cube_row
end

(0...cube_map.size).each do |row|
  (0...cube_map[row].size).each do |column|
    face = cube_map[row][column]
    next unless face

    Facing.values.each do |facing|
      adj_row = row + facing.row_offset
      next if adj_row < 0

      adj_col = column + facing.column_offset
      next if adj_col < 0

      if (adjacent_face = cube_map.dig?(adj_row, adj_col))
        face.edge_map[facing] = CubeEdge.new(from: face, to: adjacent_face, rotations: 0)
      end
    end
  end
end

faces = cube_map.flatten.compact

3.times do
  stitch_edges(faces)
end

check_all_edges(faces)

AOC.part2 do
  tile, facing = follow_path_cube(faces, path)

  1000 * tile.row + 4 * tile.column + facing.value
end
