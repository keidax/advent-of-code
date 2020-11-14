def look_and_say(sequence : String)
  sequence.chars.chunks(&.itself).map do |char, ary|
    "#{ary.size}#{char}"
  end.join
end

# Part 1
input = "1321131112"
40.times do
  input = look_and_say(input)
end
puts input.size

# Part 2
10.times do
  print '.'
  input = look_and_say(input)
end
puts input.size
