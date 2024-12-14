require_relative "aoc"

input = AOC.day(12)

class Grid
  def initialize(input)
    @grid = input.lines(chomp: true).map do |line|
      line.chars.map(&:to_sym)
    end

    @visited = Set.new
  end

  def [](position)
    row, col = position
    @grid[row][col]
  end

  def ===(position)
    row, col = position

    return false if row < 0 || col < 0
    return false if row >= @grid.size || col >= @grid[row].size

    true
  end

  def visit!(position)
    @visited << position
  end

  def visited?(position)
    @visited.include? position
  end

  def build_regions
    regions = []

    @grid.each_with_index do |row, row_index|
      row.each_with_index do |plot, col_index|
        position = [row_index, col_index]
        next if @visited.include?(position)

        regions << Region.new(position, self)
      end
    end

    regions
  end
end

class Region
  attr_reader :type
  attr_reader :plots
  attr_accessor :perimeter

  def initialize(start, grid)
    @type = grid[start]
    @plots = Set.new << start
    @perimeter = Set.new

    build(start, grid)
  end

  def <<(plot)
    @plots << plot
  end

  def price
    @plots.size * @perimeter.size
  end

  def number_of_sides
    perim = @perimeter.dup
    num_sides = 0

    until perim.empty?
      extend_side(perim)
      num_sides += 1
    end

    num_sides
  end

  def extend_side(perim)
    next_pos = perim.first
    perim.delete(perim.first)

    side = [next_pos]

    direction = nil

    if perim.find { _1.adjacent?(next_pos, :horizontal) }
      direction = :horizontal
    elsif perim.find { _1.adjacent?(next_pos, :vertical) }
      direction = :vertical
    end

    return side unless direction

    loop do
      found_same_side = nil

      side.each do |pos|
        found_same_side = perim.find { _1.adjacent?(pos, direction) }

        if found_same_side
          perim.delete(found_same_side)
          side << found_same_side
          break
        end
      end

      break unless found_same_side
    end

    side
  end

  private

  def build(start, grid)
    queue = Set.new << start

    until queue.empty?
      pos = queue.first
      queue.delete(pos)

      self << pos
      grid.visit!(pos)

      adjacent_positions(pos).each do |adj|
        unless grid === adj
          edge = PlotEdge.new(pos, adj)
          perimeter << edge
          next
        end

        if grid[adj] != type
          edge = PlotEdge.new(pos, adj)
          perimeter << edge
          next
        end

        if !grid.visited?(adj)
          queue << adj
        end
      end
    end
  end

  def adjacent_positions(pos)
    row, col = pos

    [
      [row - 1, col],
      [row + 1, col],
      [row, col - 1],
      [row, col + 1]
    ]
  end
end

class PlotEdge
  attr_reader :plot, :outside

  def initialize(plot, outside)
    @plot = plot
    @outside = outside
  end

  def adjacent?(other, direction)
    case direction
    when :horizontal
      if @plot[0] == @outside[0]
        # this is a vertical edge
        return false
      end

      same_row = @plot[0] == other.plot[0]
      same_direction = @outside[0] == other.outside[0]
      adjacent = (@plot[1] - other.plot[1]).abs == 1

      same_row && same_direction && adjacent
    when :vertical

      if @plot[1] == @outside[1]
        # this is a horizontal edge
        return false
      end

      same_column = @plot[1] == other.plot[1]
      same_direction = @outside[1] == other.outside[1]
      adjacent = (@plot[0] - other.plot[0]).abs == 1

      same_column && same_direction && adjacent
    else
      raise "bad direction #{direction.inspect}"
    end
  end
end

grid = Grid.new(input)
regions = grid.build_regions

AOC.part1 do
  regions.sum(&:price)
end

AOC.part2 do
  regions.sum { _1.number_of_sides * _1.plots.size }
end
