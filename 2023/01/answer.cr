require "../aoc"

AOC.day!(1)

def load_digits(digit_matcher : Regex) : Array(Array(String))
  AOC.lines.map do |line|
    first_digit = line.match!(digit_matcher)[0]
    last_digit = find_last_digit(line, digit_matcher)

    [first_digit, last_digit]
  end
end

# We can't use String#scan or #rindex, because it won't return overlapping matches.
# For example, with the line "twone", we must find ["two", "one"].
# Instead, work backwards from the end of the line looking for a match.
def find_last_digit(line, matcher) : String
  offset = line.size - 1
  until matcher.match(line, offset)
    offset -= 1

    raise "no match found" if offset < 0
  end
  $~[0]
end

def sum_digits(digits, digitizer) : Int32
  digitizer.call(digits[0]) * 10 + digitizer.call(digits[1])
end

def solve(regex, digitizer) : Int32
  load_digits(regex).sum do |line_digits|
    sum_digits(line_digits, digitizer)
  end
end

AOC.part1 do
  solve(/\d/, ->(d : String) { d.to_i })
end

AOC.part2 do
  pattern = /\d|one|two|three|four|five|six|seven|eight|nine/
  digitizer = ->(d : String) do
    case d
    when /\d/    then d.to_i
    when "one"   then 1
    when "two"   then 2
    when "three" then 3
    when "four"  then 4
    when "five"  then 5
    when "six"   then 6
    when "seven" then 7
    when "eight" then 8
    when "nine"  then 9
    else              raise "#{d} is not a digit"
    end
  end

  solve(pattern, digitizer)
end
