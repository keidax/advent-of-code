# Part 1
def nice?(str : String)
  vowels = str.delete("^aeiou")
  return false unless vowels.size >= 3

  return false unless str.matches?(/(.)\1/)

  return false if str.matches?(/ab|cd|pq|xy/)

  true
end

# puts nice?("ugknbfddgicrmopn")
# puts nice?("aaa")
# puts nice?("jchzalrnumimnmhp")
# puts nice?("haegwjzuvuyypxyu")
# puts nice?("dvszwmarrgswjxmb")
puts File.read_lines("input.txt").select { |line| nice?(line) }.size

# Part 2
def nice2?(str : String)
  return false unless str.matches?(/(.).\1/)

  return false unless str.matches?(/(..).*\1/)

  true
end

# puts nice2?("qjhvhtzxzqqjkmpb")
# puts nice2?("xxyxx")
# puts nice2?("uurcxstgmygtbstg")
# puts nice2?("eodomkazucvgmuy")
puts File.read_lines("input.txt").select { |line| nice2?(line) }.size
