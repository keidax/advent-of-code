min = "246515"
max = "739105"

puts force_to_rule(min)
puts force_to_rule(max)

def force_to_rule(number : String) : String
  (1..5).each do |i|
    if number[i - 1] > number[i]
      number = number[0..i - 1] + number[i - 1] + number[i + 1..-1]
    end
  end

  if number.chars.each_cons(2).none? { |(a, b)| a == b }
    number = number[0..3] + number[5] + number[5] # Duplicate the last one
  end

  number
end

num = force_to_rule(min)
count = 0

while num < max
  count += 1
  num = force_to_rule(num.succ)
end

puts num
puts count
