# Set the first 36 bits
OFF_MASK = 0xfffffffff_u64
ON_MASK  =         0x0_u64

def build_masks(input) : {UInt64, UInt64}
  off_mask = OFF_MASK
  on_mask = ON_MASK

  input.chars.reverse.each_with_index do |c, i|
    case c
    when 'X' then next
    when '0'
      off_bit = ~(1_u64 << i)
      off_mask &= off_bit
    when '1'
      on_mask |= 1_u64 << i
    end
  end

  {off_mask, on_mask}
end

def get_floating_bits(input) : Array(Int32)
  bits = [] of Int32
  input.chars.reverse.each_with_index do |c, i|
    bits << i if c == 'X'
  end
  bits
end

def floating_addresses(base_address, floating_bits) : Array(UInt64)
  floating_bits = floating_bits.dup
  bit = floating_bits.shift

  forced_on = base_address | (1_u64 << bit)
  forced_off = base_address & ~(1_u64 << bit)

  if floating_bits.empty?
    [forced_on, forced_off]
  else
    floating_addresses(forced_on, floating_bits) +
      floating_addresses(forced_off, floating_bits)
  end
end

# Part 1
memory = {} of Int32 => UInt64
off_mask = OFF_MASK
on_mask = ON_MASK

File.each_line("input.txt") do |line|
  case line
  when /mask = (\w+)/
    off_mask, on_mask = build_masks($1)
  when /mem\[(\d+)\] = (\d+)/
    index = $1.to_i
    value = $2.to_u64
    value &= off_mask
    value |= on_mask
    memory[index] = value
  end
end

puts memory.values.sum

# Part 2
memory = {} of UInt64 => UInt64

on_mask = ON_MASK
floating_bits = [] of Int32

File.each_line("input.txt") do |line|
  case line
  when /mask = (\w+)/
    _, on_mask = build_masks($1)
    floating_bits = get_floating_bits($1)
  when /mem\[(\d+)\] = (\d+)/
    base_addr = $1.to_u64
    value = $2.to_u64

    base_addr |= on_mask
    floating_addresses(base_addr, floating_bits).each do |addr|
      memory[addr] = value
    end
  end
end

puts memory.values.sum
