require "../intcode"

enum Direction : Int64
  North = 1
  South = 2
  West  = 3
  East  = 4
end

enum Status : Int64
  Wall   = 0
  Step   = 1
  Oxygen = 2
end

class Node
  property(
    x : Int32,
    y : Int32,
    status : GridStatus = :unknown,
    visited : Bool = false,
    distance : Int32 = MAX_DIST
  )

  def_equals x, y

  def self.neighbors(x, y) : Array(self)
    neighbors(x, y) { |_| true }
  end

  def self.neighbors(x, y, &) : Array(self)
    neighbors = [] of Node
    if x > 0
      node = GRID[y][x - 1]
      neighbors << node if yield node
    end
    if x + 1 < MAX_X
      node = GRID[y][x + 1]
      neighbors << node if yield node
    end
    if y > 0
      node = GRID[y - 1][x]
      neighbors << node if yield node
    end
    if y + 1 < MAX_Y
      node = GRID[y + 1][x]
      neighbors << node if yield node
    end
    neighbors
  end

  def neighbors : Array(Node)
    self.class.neighbors(x, y)
  end

  def neighbors(&) : Array(Node)
    self.class.neighbors(x, y) { |n| yield n }
  end

  def initialize(@x, @y)
  end

  def visit!
    return if visited

    neighbors = self.neighbors
    neighbors.reject! &.visited

    new_dist = self.distance + 1
    neighbors.each do |n|
      if n.distance > new_dist
        n.distance = new_dist
      end
    end

    self.visited = true
    UNVISITED.delete(self)
  end

  def known? : Bool
    self.status != :unknown
  end

  def to_s(io)
    io << status.to_s
  end

  def print
    print_at(x, y, self)
  end
end

enum GridStatus
  Unknown = 0
  Empty   = 1
  Wall    = 2
  Oxygen  = 3

  def to_s : String
    case self
    when .unknown? then " "
    when .empty?   then "."
    when .wall?    then "▓"
    when .oxygen?  then "o"
    else                "?"
    end
  end
end

input = File.read("input.txt").chomp
bot = Intcode.new(input)
bot.run

printf "\e[?25l" # hide cursor
printf "\e[2J"   # clear screen

print_at(0, 0, '#')
print_at(0, 40, '#')
print_at(40, 0, '#')
print_at(40, 40, '#')

MAX_DIST = 999_999
MAX_X    =      41
MAX_Y    =      41

UNVISITED = Array(Node).new(initial_capacity: MAX_X*MAX_Y)

GRID = Array.new(MAX_Y) do |y|
  Array(Node).new(MAX_X) do |x|
    node = Node.new(x, y)
    UNVISITED << node
    node
  end
end

x, y = 21, 21
start = GRID[y][x]
start.status = :empty
start.distance = 0
start.visit!

def step(bot, x, y, dir : Direction)
  bot.input.send dir.value
  status = Status.new(bot.output.receive)

  xoff, yoff = case dir
               when .north?
                 {0, -1}
               when .south?
                 {0, 1}
               when .east?
                 {1, 0}
               when .west?
                 {-1, 0}
               else
                 raise "asdf"
               end

  case status
  when .wall?
    wall = GRID[y + yoff][x + xoff]
    wall.status = :wall
    wall.distance = MAX_DIST
    wall.visited = true
    UNVISITED.delete(wall)

    print_at(x + xoff, y + yoff, wall)
  when .step?
    GRID[y][x].print

    x += xoff
    y += yoff
    empty = GRID[y][x]
    empty.status = :empty
  when .oxygen?
    GRID[y][x].print

    x += xoff
    y += yoff
    oxy = GRID[y][x]
    oxy.status = :oxygen
  end

  print_at(x, y, '*')
  return {x, y}
end

def print_at(x, y, thing : Node | Char)
  printf "\e[#{y + 1};#{x + 1}H#{thing.to_s}"
end

def finish(str = "")
  printf "\e[42H#{str}\n"
  puts "unvisited: #{UNVISITED.size}"
  printf "\e[?25h" # show cursor
  exit 0
end

Signal::INT.trap do
  finish "canceled"
end

def travel_to(node target, from current) : Array(Node)
  path = [] of Node
  path = attempt_travel(current, target, path) # .not_nil!
  if path.nil?
    raise "no path from #{current.x},#{current.y} to #{target.x},#{target.y}"
  else
    path.shift
    path
  end
end

# Crappy DFS version
def attempt_travel(from, to, traveled : Array(Node)) : Array(Node)?
  if from == to
    return traveled << to
  end

  new_path = traveled.dup
  new_path << from

  valid_neighbors = from.neighbors do |n|
    n == to || (
      n.status.empty? && !traveled.includes?(n)
    )
  end
  valid_neighbors.each do |neighbor|
    full_path = attempt_travel(from: neighbor, to: to, traveled: new_path)
    return full_path if full_path
  end

  nil
end

loop do
  (1..10000).each do |i|
    UNVISITED.sort_by! &.distance

    cur_node = GRID[y][x]
    next_node = UNVISITED.first

    path = travel_to next_node, from: cur_node
    while path.size > 1
      next_step = path.shift

      if next_step.x < x
        x, y = step(bot, x, y, :west)
      elsif next_step.x > x
        x, y = step(bot, x, y, :east)
      elsif next_step.y < y
        x, y = step(bot, x, y, :north)
      elsif next_step.y > y
        x, y = step(bot, x, y, :south)
      else
        raise "can't step from #{x},#{y} to #{next_step.x},#{next_step.y}"
      end
    end

    if path.one?
      next_step = path.shift

      if next_step.x < x
        x, y = step(bot, x, y, :west)
      elsif next_step.x > x
        x, y = step(bot, x, y, :east)
      elsif next_step.y < y
        x, y = step(bot, x, y, :north)
      elsif next_step.y > y
        x, y = step(bot, x, y, :south)
      else
        raise "can't step to node #{next_step}"
      end

      case next_step.status
      when .wall?
        nil
      when .empty?
        next_step.visit!
      when .oxygen?
        next_node.visit!
        finish "oxygen distance is #{next_node.distance}"
      else
        raise "bad status: #{next_node}"
      end
    end
  end
end

finish
