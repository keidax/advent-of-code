require "../aoc"

AOC.day!(17)

alias Shape = Array(UInt8)

enum Jet
  Left
  Right
end

# Custom iterators that let us work around an issue with the standard library's
# cycle type, and also read the index.
class JetCycle
  include Iterator(Jet)

  property jets : Array(Jet)
  property size : Int32
  property index = 0

  def initialize(input)
    @jets = input.strip.chars.map do |c|
      case c
      when '<' then Jet::Left
      when '>' then Jet::Right
      else          raise "bad input character #{c}"
      end
    end

    @size = jets.size
  end

  def next
    next_jet = @jets[@index]

    @index += 1
    @index = 0 if @index >= @size

    next_jet
  end

  def reset
    @index = 0
  end
end

class ShapeCycle
  include Iterator(Shape)

  # Include blocks as they appear, with 2 units of space on the left
  SHAPES = [
    # @@@@
    [
      0b0011110_u8,
    ],
    #  @
    # @@@
    #  @
    [
      0b0001000_u8,
      0b0011100_u8,
      0b0001000_u8,
    ],
    #   @
    #   @
    # @@@
    [
      0b0000100_u8,
      0b0000100_u8,
      0b0011100_u8,
    ],
    # @
    # @
    # @
    # @
    [
      0b0010000_u8,
      0b0010000_u8,
      0b0010000_u8,
      0b0010000_u8,
    ],
    # @@
    # @@
    [
      0b0011000_u8,
      0b0011000_u8,
    ],
  ] of Shape

  property shapes : Array(Shape) = SHAPES.map(&.reverse)
  property index = 0
  property size : Int32 = SHAPES.size

  def next
    next_shape = shapes[@index].clone

    @index += 1
    @index = 0 if @index >= @size

    next_shape
  end
end

def shift!(shape, jet : Jet)
  case jet
  in Jet::Left
    if shape.all? { |row| row.bit(6) == 0 }
      shape.map! { |row| row << 1 }
    end
  in Jet::Right
    if shape.all? { |row| row.bit(0) == 0 }
      shape.map! { |row| row >> 1 }
    end
  end
end

def reverse_shift!(shape, jet)
  reverse = if jet == Jet::Left
              Jet::Right
            else
              Jet::Left
            end

  shift!(shape, reverse)
end

def intersect?(shape, stack, height)
  if height >= stack.size
    return false
  end

  if height < 0
    # hit the floor
    return true
  end

  slice = height...(height + shape.size)

  slice.each_with_index do |i, j|
    return false if i >= stack.size
    stack_line = stack[i]
    shape_line = shape[j]
    return true if stack_line & shape_line > 0
  end

  false
end

def merge_stack!(shape, stack, height)
  slice = height...(height + shape.size)

  slice.each do |i|
    if stack[i]?
      stack[i] |= shape.shift { 0 }
    end
  end

  stack.concat(shape)
end

def add_to_stack!(shape, stack, jets)
  # begin 3 rows above the top of the stack
  height = stack.size + 3

  loop do
    jet = jets.next

    shift!(shape, jet)
    if intersect?(shape, stack, height)
      reverse_shift!(shape, jet)
    end

    if intersect?(shape, stack, height - 1)
      merge_stack!(shape, stack, height)
      break
    end

    height -= 1
  end
end

def height_added_by_rocks(blocks, shapes, jets, count)
  prev_height = blocks.size

  shapes.first(count).each do |shape|
    add_to_stack!(shape, blocks, jets)
  end

  blocks.size - prev_height
end

AOC.part1 do
  blocks = [] of UInt8
  shapes = ShapeCycle.new
  jets = JetCycle.new(AOC.input)

  height_added_by_rocks(blocks, shapes, jets, count: 2022)
end

# How many rows of rocks to inspect looking for a repeating cycle.
# If this is too low, a false cycle may be detected.
CYCLE_DEPTH_CHECK = 35

TOTAL_ROCKS = 1_000_000_000_000i64

def find_cycle(blocks, shapes, jets)
  block_cache = {} of Array(UInt8) => {height: Int32, rocks: Int32, jet_index: Int32}
  rocks = 0

  loop do
    shape = shapes.next.as(Array(UInt8))

    add_to_stack!(shape, blocks, jets)
    rocks += 1

    cache_seg = blocks.last(CYCLE_DEPTH_CHECK)
    if res = block_cache[cache_seg]?
      return {rocks, res}
    else
      block_cache[cache_seg.clone] = {height: blocks.size, rocks: rocks, jet_index: jets.index}
    end
  end
end

def check_cycle(blocks, shapes, jets, cycle_length, expected_height, expected_jets)
  shapes.first(cycle_length).each do |shape|
    add_to_stack!(shape, blocks, jets)
  end

  if blocks.size != expected_height
    p! blocks.size, expected_height
    raise "false cycle"
  end

  if jets.index != expected_jets
    raise "false cycle"
  end
end

AOC.part2 do
  blocks = [] of UInt8
  shapes = ShapeCycle.new
  jets = JetCycle.new(AOC.input)

  rocks, result = find_cycle(blocks, shapes, jets)

  cycle_length = rocks - result[:rocks]
  cycle_height = blocks.size - result[:height]

  expected_height = blocks.size + cycle_height

  check_cycle(blocks, shapes, jets, cycle_length, expected_height, result[:jet_index])
  check_cycle(blocks, shapes, jets, cycle_length, expected_height + cycle_height, result[:jet_index])

  remaining_rocks = TOTAL_ROCKS - rocks - cycle_length - cycle_length
  height_from_remaining_cycles = (remaining_rocks // cycle_length) * cycle_height
  extra_rocks = remaining_rocks % cycle_length

  prev_height = blocks.size
  extra_height = height_added_by_rocks(blocks, shapes, jets, count: extra_rocks)

  prev_height.to_i64 + height_from_remaining_cycles + extra_height
end
