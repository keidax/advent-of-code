require "../aoc"

AOC.day!(9)

motions = [] of { {Int32, Int32}, Int32 }

AOC.each_line do |line|
  raise "bad line '#{line}'" unless line =~ /(.) (\d+)/

  dir = case $1
        when "L" then {-1, 0}
        when "R" then {1, 0}
        when "U" then {0, -1}
        when "D" then {0, 1}
        else          raise "bad direction #{$1}"
        end

  motions << {dir, $2.to_i}
end

def new_tail(head, tail)
  head_x, head_y = head
  tail_x, tail_y = tail

  if head_x == tail_x
    # in the same row
    if head_y - tail_y > 1
      tail_y = head_y - 1
    elsif head_y - tail_y < -1
      tail_y = head_y + 1
    end
  elsif head_y == tail_y
    # in the same column
    if head_x - tail_x > 1
      tail_x = head_x - 1
    elsif head_x - tail_x < -1
      tail_x = head_x + 1
    end
  elsif (head_x - tail_x).abs == 1 && (head_y - tail_y).abs == 1
    # diagonally adjacent, don't need to move
  else
    # diagonal step
    if head_x > tail_x
      tail_x += 1
    else
      tail_x -= 1
    end

    if head_y > tail_y
      tail_y += 1
    else
      tail_y -= 1
    end
  end

  {tail_x, tail_y}
end

def tail_positions(motions, tail_size)
  rope = Array.new(tail_size + 1, {0, 0})
  visited = Set{rope.last}

  motions
    .flat_map { |dir, count| Array.new(count, dir) }
    .each do |offset|
      head = rope[0]
      head = {head[0] + offset[0], head[1] + offset[1]}
      rope[0] = head

      (1..tail_size).each do |i|
        rope[i] = new_tail(rope[i - 1], rope[i])
      end

      visited << rope.last
    end

  visited.size
end

AOC.part1 { tail_positions(motions, 1) }
AOC.part2 { tail_positions(motions, 9) }
