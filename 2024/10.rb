require_relative "aoc"

input = AOC.day(10)

grid = input.lines(chomp: true).map { _1.chars.map(&:to_i) }

row_range = (0...grid.size)
col_range = (0...grid[0].size)

trails = Hash.new { |h, k| h[k] = Set.new }

trailheads = Set.new
peaks = Set.new

# build the trail network:
# trails[pos] returns the reachable positions from pos
grid.each_with_index do |positions, row|
  positions.each_with_index do |height, col|
    position = [row, col]

    trailheads << position if height == 0
    peaks << position if height == 9

    [
      [row + 1, col],
      [row - 1, col],
      [row, col + 1],
      [row, col - 1]
    ].each do |adj_position|
      next unless adj_position in [^row_range, ^col_range]

      adj_height = grid[adj_position[0]][adj_position[1]]
      next unless adj_height == height + 1

      trails[position] << adj_position
    end
  end
end

def score(trailhead, trails)
  positions = [trailhead]

  9.times do
    positions = reachable_from(positions, trails)
  end

  positions.size
end

# given a set of positions, return all positions immediately reachable from any
#   of the input positions
def reachable_from(positions, trails)
  positions.map { trails[_1] }.reduce(:|)
end

AOC.part1 do
  trailheads.sum { score(_1, trails) }
end

# Rating calculation with automatic memoization:
#   the rating for any position is the sum of the ratings from the reachable
#   adjacent positions
ratings = Hash.new { |h, k| h[k] = calculate_rating(k, trails, h) }
peaks.each { ratings[_1] = 1 }

def calculate_rating(position, trails, ratings)
  adjacent_positions = trails[position]
  adjacent_positions.sum { |adj_pos| ratings[adj_pos] }
end

AOC.part2 do
  trailheads.sum { ratings[_1] }
end
