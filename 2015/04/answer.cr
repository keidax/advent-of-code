require "./md5"

secret = "bgvyzdsv"

# Part 1
start = 1
loop do
  md5 = MD5Reader.new(IO::Memory.new("#{secret}#{start}"))
  break if md5.to_s.starts_with?("00000")
  start += 1
end

puts start

# Part 2
# keep the `start` we already computed
loop do
  md5 = MD5Reader.new(IO::Memory.new("#{secret}#{start}"))
  break if md5.to_s.starts_with?("000000")
  start += 1
end
puts start
