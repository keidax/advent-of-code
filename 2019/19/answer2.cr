require "../intcode"

INPUT = File.read("./input.txt").chomp

def pulled?(x : Int64, y : Int64)
  bot_program = Intcode.new(INPUT, [x, y])
  bot_program.run
  bot_program.output.receive == 1
end

Y_CACHE = Array({Int64, Int64}).new

def find_beam_y(x : Int64) : Int64
  y = Y_CACHE.find({0, 0_i64}) { |val| val[0] < x }[1]

  until pulled?(x, y)
    y += 1
  end

  Y_CACHE.unshift({x, y})
  return y
end

def ship_fits_at?(x : Int64)
  y = find_beam_y(x)
  pulled?(x - 99, y + 99)
end

prev_x = 100_i64
current_x = 200_i64

until ship_fits_at?(current_x)
  print '>'
  prev_x = current_x
  current_x *= 2
end

range = ((prev_x + 1)..current_x)
found_x = range.bsearch do |x|
  print '/'
  ship_fits_at?(x)
end.not_nil!

# Binary search gets us most of the way there, but the last few steps are discontinuous.
# Manually scan the final section
x = found_x
50.times do |i|
  if ship_fits_at?(found_x - i)
    x = found_x - i
  end
end

y = find_beam_y(x)
puts (x - 99) * 10_000 + y # DON'T add 99 to y
