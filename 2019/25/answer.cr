require "../intcode"

input = File.read("input.txt")

bot = Intcode.new(input)
bot.run

def next_line(bot) : String
  line = ""
  loop do
    next_char = bot.output.receive.chr

    if next_char == '\n'
      return line
    end

    line += next_char
  end
end

class Room
  property name : String
  property doors : Hash(String, Room)
  property items : Array(String)

  UNKNOWN = Room.new("UNKNOWN", [] of String, [] of String)

  def initialize(@name, doors, @items)
    @doors = Hash(String, Room).new
    doors.each do |door_name|
      @doors[door_name] = UNKNOWN
    end
  end
end

rooms_by_name = Hash(String, Room).new
prev_room = nil
prev_direction = ""

opposite_direction = {
  "south" => "north",
  "north" => "south",
  "east"  => "west",
  "west"  => "east",
}

lines = [] of String

def get_room(rooms_by_name, lines) : Room
  lines.delete("")
  lines.delete("Command?")

  until lines.first =~ /== (.*) ==/
    lines.shift
  end
  room_name = $~[1].not_nil!

  until lines.first =~ /Doors here lead:/
    lines.shift
  end
  lines.shift

  doors = [] of String
  while lines.first? && /- (.*)/ =~ lines.first
    doors << $~[1].not_nil!
    lines.shift
  end

  items = [] of String
  if lines.first? && lines.first =~ /Items here:/
    lines.shift
    while lines.first? && /- (.*)/ =~ lines.first
      items << $~[1].not_nil!
      lines.shift
    end
  end

  lines.clear

  if rooms_by_name[room_name]?
    room = rooms_by_name[room_name]
    room.items = items
  else
    room = Room.new(room_name, doors, items)
    rooms_by_name[room_name] = room
  end

  room
end

items = Set(String).new

ITEM_BLACKLIST = [
  "infinite loop",
  "escape pod",
  "giant electromagnet",
  "photons",
  "molten lava",
]

loop do
  line = next_line(bot)
  puts line

  if line == "Command?"
    room = get_room(rooms_by_name, lines)

    takeable_items = room.items - ITEM_BLACKLIST
    takeable_items.each do |item|
      send_command(bot, "take #{item}")

      loop do
        line = next_line(bot)
        puts line
        break if line == "Command?"
      end
    end

    if prev_room && prev_room.doors[prev_direction]? == Room::UNKNOWN
      prev_room.doors[prev_direction] = room
      room.doors[opposite_direction[prev_direction]] = prev_room
    end

    if room.name == "Security Checkpoint"
      direction = room.doors.find do |dir, room|
        room == Room::UNKNOWN
      end
      direction = direction.not_nil![0]

      find_correct_weight(bot, direction)
      break
    end

    prev_rooms = [prev_room] of Room?

    next_direction = move_towards(room, Room::UNKNOWN, prev_rooms)

    if next_direction
      prev_room = room
      prev_direction = next_direction
      send_command(bot, next_direction)
      next
    end

    next_direction = move_towards(room, Room::UNKNOWN, [] of Room)

    if next_direction
      prev_room = room
      prev_direction = next_direction
      send_command(bot, next_direction)
      next
    end
  else
    lines << line
  end
end

DIRECTION_ORDER = ["west", "south", "north", "east"]

def move_towards(starting_room, target : String | Room, previous_rooms : Array(Room?)) : String?
  visited = Set(Room){starting_room}
  visited.concat(previous_rooms.compact)

  # Try to sort the doors so the security checkpoint will be visited last
  # (This way all the items are collected)
  available_directions = DIRECTION_ORDER.select { |dir| starting_room.doors.has_key? dir }

  # First check if any directly adjacent rooms are the target
  available_directions.each do |direction|
    next_room = starting_room.doors[direction]

    if target.is_a?(String) && next_room.name == target
      return direction
    elsif target == next_room
      return direction
    end
  end

  # Then do a DFS for the target
  available_directions.each do |direction|
    next_room = starting_room.doors[direction]
    next if visited.includes?(next_room)

    next_visit = Deque(Room){next_room}

    while next_visit.any?
      next_room = next_visit.shift
      next if visited.includes? next_room

      visited << next_room

      if target.is_a?(String) && next_room.name == target
        return direction
      elsif target == next_room
        return direction
      end

      to_visit = next_room.doors.values
      to_visit.reject! do |room|
        visited.includes? room
      end

      to_visit.each do |room|
        next_visit.unshift room
      end
    end
  end
end

def send_command(bot, command)
  puts command

  command.each_char do |char|
    bot.input.send char.ord.to_i64
  end

  bot.input.send '\n'.ord.to_i64
end

def find_correct_weight(bot, direction)
  all_items = get_items(bot)

  prev_comb = all_items

  (2..all_items.size).each do |size|
    all_items.each_combination(size) do |comb|
      items_to_drop = prev_comb - comb
      items_to_take = comb - prev_comb

      items_to_take.each { |item| take_item(bot, item) }
      items_to_drop.each { |item| drop_item(bot, item) }

      send_command(bot, direction)
      loop do
        line = next_line(bot)
        puts line

        break if line == "Command?"
      rescue Channel::ClosedError
        return
      end

      prev_comb = comb
    end
  end
end

def get_items(bot)
  items = [] of String

  send_command(bot, "inv")

  loop do
    line = next_line(bot)
    puts line

    if /- (.*)/ =~ line
      items << $~[1].not_nil!
    end

    break if line == "Command?"
  end

  items
end

def drop_item(bot, item)
  send_command(bot, "drop #{item}")

  loop do
    line = next_line(bot)
    puts line

    break if line == "Command?"
  end
end

def take_item(bot, item)
  send_command(bot, "take #{item}")

  loop do
    line = next_line(bot)
    puts line

    break if line == "Command?"
  end
end
