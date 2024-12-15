require_relative "aoc"

class Tile
  attr_reader :row, :col

  def initialize(grid, row, col)
    @grid = grid
    @row = row
    @col = col

    @grid[row][col] = self
  end

  def can_move?(direction) = raise "unimplemented"

  def get_tile(direction)
    case direction
    when :up
      return nil if @row <= 0
      @grid[@row - 1][@col]
    when :down
      return nil if @row + 1 >= @grid.size
      @grid[@row + 1][@col]
    when :left
      return nil if @col <= 0
      @grid[@row][@col - 1]
    when :right
      return nil if @col + 1 >= @grid[@row].size
      @grid[@row][@col + 1]
    else
      raise "bad direction"
    end
  end

  def move(direction)
    next_tile = get_tile(direction)
    next_tile&.move(direction)

    @grid[@row][@col] = nil

    case direction
    when :up
      @row -= 1
    when :down
      @row += 1
    when :left
      @col -= 1
    when :right
      @col += 1
    end

    @grid[@row][@col] = self
  end

  def gps_coordinate
    @row * 100 + @col
  end
end

class Wall < Tile
  def can_move?(_) = false
end

class Box < Tile
  def can_move?(direction)
    next_tile = get_tile(direction)
    return true if next_tile.nil?
    next_tile.can_move?(direction)
  end
end

class BigBox < Box
  def initialize(...)
    super
    @grid[@row][@col + 1] = self
  end

  # Return an array of one or two tiles in the given direction
  # @return [Array<Tile>]
  def get_tiles(direction)
    case direction
    when :up
      return nil if @row <= 0
      [
        @grid[@row - 1][@col],
        @grid[@row - 1][@col + 1]
      ].uniq
    when :down
      return nil if @row + 1 >= @grid.size
      [
        @grid[@row + 1][@col],
        @grid[@row + 1][@col + 1]
      ].uniq
    when :left
      return nil if @col <= 0
      [@grid[@row][@col - 1]]
    when :right
      return nil if @col + 2 >= @grid[@row].size
      [@grid[@row][@col + 2]]
    else
      raise "bad direction"
    end
  end

  def can_move?(direction)
    get_tiles(direction).compact.all? { _1.can_move?(direction) }
  end

  def move(direction)
    next_tiles = get_tiles(direction).compact
    next_tiles&.each { _1.move(direction) }

    @grid[@row][@col] = nil
    @grid[@row][@col + 1] = nil

    case direction
    when :up
      @row -= 1
    when :down
      @row += 1
    when :left
      @col -= 1
    when :right
      @col += 1
    end

    @grid[@row][@col] = self
    @grid[@row][@col + 1] = self
  end
end

class Pusher < Tile
  def try_move(direction)
    next_tile = get_tile(direction)
    if next_tile.nil? || next_tile.can_move?(direction)
      move(direction)
    end
  end

  def process_instructions(instructions)
    instructions.chars.each do |inst|
      case inst
      when "^" then try_move(:up)
      when "v" then try_move(:down)
      when "<" then try_move(:left)
      when ">" then try_move(:right)
      else raise "bad instruction"
      end
    end
  end
end

def build_grid(grid_input)
  robot = nil
  grid = Array.new(grid_input.size) { Array.new(grid_input[0].size, nil) }

  grid_input.each_with_index do |line, row|
    line.chars.each_with_index do |char, col|
      klass = case char
      when "#" then Wall
      when "O" then Box
      when "[" then BigBox
      when "]" then nil
      when "@" then Pusher
      when "." then nil
      end

      tile = klass&.new(grid, row, col)
      robot = tile if klass == Pusher
    end
  end

  [grid, robot]
end

def embiggen(input)
  input.map do |line|
    line.gsub("#", "##")
      .gsub("O", "[]")
      .gsub(".", "..")
      .gsub("@", "@.")
  end
end

input = AOC.day(15)

grid_input, instructions = input.line_sections
instructions = instructions.join("")

AOC.part1 do
  grid, robot = build_grid(grid_input)
  robot.process_instructions(instructions)
  grid.flatten.select { Box === _1 }.sum(&:gps_coordinate)
end

AOC.part2 do
  grid, robot = build_grid(embiggen(grid_input))
  robot.process_instructions(instructions)
  grid.flatten.select { Box === _1 }.uniq.sum(&:gps_coordinate)
end
