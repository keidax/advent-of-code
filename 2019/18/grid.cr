class Grid
  @data : Array(Array(Char))

  def initialize(input : String)
    @data = Array(Array(Char)).new

    input.each_line do |line|
      @data << line.chars
    end
  end

  def [](x, y) : Char
    @data[y][x]
  end

  alias Neighbor = {x: Int32, y: Int32}

  def neighbors(x, y, exclude : Neighbor = {x: -1, y: -1}) : Array(Neighbor)
    directions = [
      {0, 1},
      {1, 0},
      {0, -1},
      {-1, 0},
    ]

    neighbors = [] of Neighbor

    directions.each do |x_offset, y_offset|
      new_x = x + x_offset
      new_y = y + y_offset

      next if new_y < 0 || new_y >= @data.size
      next if new_x < 0 || new_x >= @data[0].size
      next if new_x == exclude[:x] && new_y == exclude[:y]

      char = @data[new_y][new_x]
      next if char == '#'

      neighbors << {x: new_x, y: new_y}
    end

    neighbors
  end

  def find(char) : Neighbor
    @data.each_with_index do |row, y|
      row.each_with_index do |char, x|
        if char == '@'
          return {x: x, y: y}
        end
      end
    end

    raise "could not find char #{char.inspect}"
  end
end
