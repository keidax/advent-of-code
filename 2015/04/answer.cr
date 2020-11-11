require "./md5"

secret = "bgvyzdsv"
start = 0
loop do
  start += 1
  md5 = MD5Reader.new(IO::Memory.new("#{secret}#{start}"))
  break if md5.to_s.starts_with?("00000")
  print '.' if start % 1000 == 0
end
puts
puts start
