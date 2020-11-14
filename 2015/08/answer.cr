def memory_size(str : String)
  inner_str = str[1...-1] # trim the outer ""

  # Substitute escapes (use _ to not accidentally produce more escapes, like "\\xab")
  inner_str = inner_str.gsub(%q(\\), '_').gsub(%q(\"), '_')
  inner_str = inner_str.gsub(/\\x[[:xdigit:]]{2}/, '_')

  str.size - inner_str.size
end

def escaped_size(str : String)
  chars_needing_escape = str.count(%q("\))
  str.size + chars_needing_escape + 2
end

# Part 1
mem_sum = 0
File.each_line("input.txt") do |line|
  mem_sum += memory_size(line)
end
puts mem_sum

# Part 2
escape_sum = 0
File.each_line("input.txt") do |line|
  escape_sum += escaped_size(line) - line.size
end
puts escape_sum
