seats = File.read_lines("input.txt").map do |line|
  # Seat code equals the input mapped to binary
  line.tr("FBLR", "0101").to_i(base: 2)
end.sort

# Part 1
puts seats.last

# Part 2
seats.each_cons_pair do |a, b|
  if a + 1 != b
    puts a + 1
    break
  end
end
