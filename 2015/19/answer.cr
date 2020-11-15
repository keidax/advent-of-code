replacements = {} of String => Array(String)

molecule = ""

File.each_line("input.txt") do |line|
  if line.match(/(\w+) => (\w+)/)
    replacements[$1] ||= [] of String
    replacements[$1] << $2
  else
    molecule = line
  end
end

# Part 1
molecules = [] of String
replacements.each do |input, outputs|
  outputs.each do |output|
    molecule.scan(/#{input}/) do |match|
      new_str = String.build do |str|
        str << match.pre_match
        str << output
        str << match.post_match
      end
      molecules << new_str
    end
  end
end
pp molecules.uniq.size

# Part 2
inverse_rules = [] of {String, String}

replacements.each do |input, outputs|
  outputs.each do |output|
    inverse_rules << {output, input}
  end
end

inverse_rules.sort! do |a, b|
  a[0].count("A-Z") <=> b[0].count("A-Z")
end.reverse!

# Go backwards, trying each replacement in a loop, starting with the largest.
# I don't think this would work on every possible input, but it's enough for
# this problem.
steps = 0
loop do
  inverse_rules.each do |output, input|
    replaced = false

    molecule = molecule.sub(output) do
      steps += 1
      replaced = true
      input
    end

    break if replaced
  end

  break if molecule == "e"
  # We ended up with one molecule that's not 'e'
  raise "got the wrong output" if molecule.count("A-Z") == 1
end

pp steps
