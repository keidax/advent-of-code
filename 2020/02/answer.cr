class Password
  property char : Char
  property lower : Int32
  property upper : Int32
  property password : String

  def initialize(@char, @lower, @upper, @password)
  end
end

passwords = File.read_lines("input.txt").map do |line|
  line =~ /(\d+)-(\d+) (\w): (\w+)/

  Password.new(
    char = $3.not_nil!.chars[0],
    lower = $1.not_nil!.to_i,
    upper = $2.not_nil!.to_i,
    password = $4.not_nil!
  )
end

# Part 1
puts passwords.count { |pw|
  valid_range = pw.lower..pw.upper
  char_count = pw.password.count(pw.char)

  valid_range.includes?(char_count)
}

# Part 2
puts passwords.count { |pw|
  chars = pw.password.chars

  match_lower = chars[pw.lower - 1] == pw.char
  match_upper = chars[pw.upper - 1] == pw.char

  match_lower ^ match_upper
}
