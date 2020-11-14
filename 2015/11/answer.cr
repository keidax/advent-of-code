STRAIGHTS = ('a'..'x').map do |char|
  char.to_s + (char + 1) + (char + 2)
end.reject do |str|
  str.count("ilo") > 0
end
STRAIGHT_REGEX = /#{STRAIGHTS.join("|")}/

DOUBLE_PAIR_REGEX = /(.)\1.*(.)\2/

def valid_password?(str : String)
  str.count("ilo") == 0 &&
    str.matches?(STRAIGHT_REGEX) &&
    str.matches?(DOUBLE_PAIR_REGEX)
end

# Part 1
password = "cqjxjnds"
loop do
  password = password.succ
  break if valid_password?(password)
end

puts password

# Part 2
loop do
  password = password.succ
  break if valid_password?(password)
end
puts password
