enum Direction
  East  =   0
  North =  90
  West  = 180
  South = 270
end

instructions = [] of {Char, Int32}

File.each_line("input.txt") do |line|
  instructions << {line[0], line[1..].to_i}
end

# Treating east as positive in the x direction
# and north as positive in the y direction.

# Part 1
dir = Direction::East
x_pos, y_pos = 0, 0

instructions.each do |action, val|
  case action
  when 'N' then y_pos += val
  when 'S' then y_pos -= val
  when 'E' then x_pos += val
  when 'W' then x_pos -= val
  when 'L' then dir = Direction.from_value (dir.to_i + val) % 360
  when 'R' then dir = Direction.from_value (dir.to_i - val) % 360
  when 'F'
    case dir
    when .north? then y_pos += val
    when .south? then y_pos -= val
    when .east?  then x_pos += val
    when .west?  then x_pos -= val
    end
  end
end
puts x_pos.abs + y_pos.abs

# Part 2
x_pos, y_pos = 0, 0
way_x, way_y = 10, 1

def rotate_waypoint(way_x, way_y, degs) : {Int32, Int32}
  degs %= 360
  case degs
  when   0 then {way_x, way_y}
  when  90 then {-way_y, way_x}
  when 180 then {-way_x, -way_y}
  when 270 then {way_y, -way_x}
  else
    raise "not a cardinal direction: #{degs}"
  end
end

instructions.each do |action, val|
  case action
  when 'N' then way_y += val
  when 'S' then way_y -= val
  when 'E' then way_x += val
  when 'W' then way_x -= val
  when 'L' then way_x, way_y = rotate_waypoint(way_x, way_y, val)
  when 'R' then way_x, way_y = rotate_waypoint(way_x, way_y, -val)
  when 'F'
    x_pos += way_x*val
    y_pos += way_y * val
  end
end
puts x_pos.abs + y_pos.abs
