BASE_DATA = File.read("input.txt").chomp.each_char.map(&.to_u8).to_a * 10_000
# BASE_DATA = "03081770884921959731165446850517".each_char.map(&.to_u8).to_a * 10_000

SIZE      = BASE_DATA.size
OFFSET    = BASE_DATA[0...7].join("").to_i
DATA_SIZE = SIZE - OFFSET

DATA = Array(Array(UInt8)).new(101) { Array(UInt8).new(DATA_SIZE, 0) }
DATA[0][0..] = BASE_DATA[OFFSET..]

(1..100).each do |phase|
  DATA[phase][-1] = BASE_DATA.last # Last digit is always the same

  (0...(DATA_SIZE - 1)).reverse_each do |digit|
    DATA[phase][digit] = (DATA[phase - 1][digit] + DATA[phase][digit + 1]) % 10
  end
  print '.'
end
puts

8.times do |i|
  print DATA[100][i]
end
puts
