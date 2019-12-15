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
  )

  def_equals x, y

  def initialize(@x, @y)
  end

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

  def fill_wall!
    self.status = :wall

    potential_walls = neighbors &.status.unknown?

    potential_walls.each do |maybe_wall|
      if maybe_wall.neighbors.all? &.status.wall?
        maybe_wall.fill_wall!
        maybe_wall.print
      end
    end
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
    when .oxygen?  then "O"
    else                "?"
    end
  end
end

input = File.read("input.txt").chomp
bot = Intcode.new(input)
bot.run

printf "\e[?25l" # hide cursor
printf "\e[2J"   # clear screen

MAX_DIST = 999_999
MAX_X    =      41
MAX_Y    =      41

GRID = Array.new(MAX_Y) do |y|
  Array(Node).new(MAX_X) do |x|
    Node.new(x, y)
  end
end

x, y = 21, 21
start = GRID[y][x]
start.status = :empty

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
    wall.fill_wall!

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

    OXYGEN << oxy
  else
    raise "wat?"
  end

  print_at(x, y, '*')
  return {x, y}
end

def print_at(x, y, thing : Node | Char)
  printf "\e[#{y + 1};#{x + 1}H#{thing.to_s}"
end

def finish(str = "")
  printf "\e[42H#{str}\n"
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

OXYGEN = [] of Node

visit_queue = [] of Node
visit_queue.concat GRID[y][x].neighbors

while visit_queue.any?
  cur_node = GRID[y][x]
  next_node = visit_queue.shift

  next if next_node.status.wall?

  path = travel_to next_node, from: cur_node
  orig_path = path.dup
  while path.size > 0
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

  cur_node = GRID[y][x]
  cur_node.neighbors(&.status.unknown?).each do |n|
    visit_queue.unshift n
  end
end

mins = 0

loop do
  next_oxygen = [] of Node
  OXYGEN.each do |oxy|
    next_oxygen.concat oxy.neighbors { |n| n.status.empty? }
  end

  break if next_oxygen.empty?
  mins += 1

  next_oxygen.uniq!
  next_oxygen.each do |oxy|
    oxy.status = :oxygen
    oxy.print
  end

  OXYGEN.clear
  OXYGEN.concat next_oxygen
end

finish "Took #{mins} minutes to fill with oxygen"
