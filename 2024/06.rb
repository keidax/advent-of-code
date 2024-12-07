require_relative "aoc"

input = AOC.day(6)

grid = input.lines(chomp: true).map { _1.chars.map(&:to_sym) }

class Guard
  UP = 1
  RIGHT = 2
  DOWN = 4
  LEFT = 8

  attr_accessor :row, :col, :dir

  attr_reader :grid

  def initialize(grid)
    @grid = grid
    @row, @col = find_start(grid)
    @dir = UP

    @max_row = @grid.size
    @max_col = @grid[0].size

    @start_pos = [@row, @col]

    @visited = Array.new(grid.size) { Array.new(grid[0].size, 0) }
    @visited[@row][@col] = UP

    @obstructions = Set.new
  end

  def initialize_copy(*args)
    super

    # After duplicating the guard in #check_obstruction, we will continue to
    # mutate @visited while checking for a loop. Make sure we're mutating a
    # deep copy, not the original @visited
    @visited = @visited.map(&:dup)
  end

  def turn_right(direction)
    (direction << 1) % 15
  end

  def find_start(grid)
    (0...grid.size).each do |row|
      (0...grid[0].size).each do |col|
        return [row, col] if grid[row][col] == :^
      end
    end

    nil
  end

  # Advance the guard by one position
  # Returns
  # - true if the guard can keep moving
  # - false if the guard has reached the edge of the grid
  # - :loop if the guard has returned to a position already marked in @visited
  def next_step
    next_row = @row
    next_col = @col
    next_dir = @dir

    case @dir
    when UP
      next_row -= 1
      return false if next_row < 0
    when DOWN
      next_row += 1
      return false if next_row >= @max_row

    when RIGHT
      next_col += 1
      return false if next_col >= @max_col
    when LEFT
      next_col -= 1
      return false if next_col < 0
    end

    if @grid[next_row][next_col] == :"#"
      next_row = @row
      next_col = @col
      next_dir = turn_right(@dir)
    end

    if (@visited[next_row][next_col] & next_dir) > 0
      return :loop
    end

    @visited[next_row][next_col] |= next_dir

    @row, @col, @dir = next_row, next_col, next_dir
    true
  end

  # Advance the guard by one position, while checking whether an obstruction
  # placed directly ahead would cause a loop
  def next_step_obstruction
    next_row = @row
    next_col = @col
    next_dir = @dir

    case @dir
    when UP
      next_row -= 1
      return false if next_row < 0
    when DOWN
      next_row += 1
      return false if next_row >= @max_row

    when RIGHT
      next_col += 1
      return false if next_col >= @max_col
    when LEFT
      next_col -= 1
      return false if next_col < 0
    end

    if @grid[next_row][next_col] == :"#"
      next_row = @row
      next_col = @col
      next_dir = turn_right(@dir)
    else
      check_obstruction(next_row, next_col)
    end

    @visited[next_row][next_col] |= next_dir

    @row, @col, @dir = next_row, next_col, next_dir
    true
  end

  # Check if adding an obstruction at the given position would force the guard
  # into an infinite loop based on her current position.
  def check_obstruction(obs_row, obs_col)
    if @visited[obs_row][obs_col] > 0
      # The guard has already passed through this point, which means we've
      # already checked for an obstruction here
      return
    end

    orig_cell = @grid[obs_row][obs_col]
    @grid[obs_row][obs_col] = :"#"

    duplicate = dup
    if duplicate.check_for_loop?
      @obstructions << [obs_row, obs_col]
    end

    @grid[obs_row][obs_col] = orig_cell
  end

  def check_for_loop?
    while (val = next_step)
      # returned to the same location
      return true if val == :loop
    end

    # exited the grid
    false
  end

  def visited_count
    @visited.sum { |row| row.count { _1 > 0 } }
  end

  def obstruction_count
    @obstructions.delete(@start_pos).size
  end
end

AOC.part1 do
  guard = Guard.new(grid)
  loop { break unless guard.next_step }
  guard.visited_count
end

AOC.part2 do
  guard = Guard.new(grid)
  loop { break unless guard.next_step_obstruction }
  guard.obstruction_count
end
