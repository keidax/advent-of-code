require "../expect"

require "./recursive_grid"

expect "Example 1", {<<-EX}, 26
         A           
         A           
  #######.#########  
  #######.........#  
  #######.#######.#  
  #######.#######.#  
  #######.#######.#  
  #####  B    ###.#  
BC...##  C    ###.#  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE..#######...###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       
EX

expect "Example 3", {<<-EX}, 396
             Z L X W       C                 
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M
EX

puts answer File.read("input.txt")

def clean_up(input) : String
  char_data = input.lines.map &.chars

  loop do
    changes = 0

    char_data.each_with_index do |row, y|
      row.each_with_index do |char, x|
        next unless char == '.'

        neighbors = {
          char_data[y + 1][x],
          char_data[y - 1][x],
          char_data[y][x + 1],
          char_data[y][x - 1],
        }

        if neighbors.count('#') >= 3
          # This is a dead end
          char_data[y][x] = '#'
          changes += 1
        end
      end
    end

    break if changes == 0
  end

  char_data.map(&.join("")).join('\n')
end

def answer(input) : Int32
  input = clean_up(input)
  grid = RecursiveGrid.new(input)

  start_tile = grid.start_portal
  end_tile = grid.end_portal

  unvisited = Set{start_tile, end_tile}
  start_tile.distance = 0

  while unvisited.any?
    next_tile = unvisited.min_by &.distance
    unvisited.delete(next_tile)

    adjacent_distance = next_tile.distance + 1
    unvisited_neighbors = next_tile.neighbors.reject! &.visited?

    unvisited_neighbors.each { |t| t.distance = Math.min(t.distance, adjacent_distance) }
    unvisited.concat(unvisited_neighbors)

    next_tile.visited = true
    break if next_tile == end_tile
  end

  end_tile.distance
end
