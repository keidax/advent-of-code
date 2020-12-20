require "string_scanner"

more_rules = true
rule_lines = [] of String
data_lines = [] of String

File.each_line("input.txt") do |line|
  if line.blank?
    more_rules = false
    next
  end

  if more_rules
    rule_lines << line
  else
    data_lines << line
  end
end

alias Rule = Char | Array(Int32) | Array(Rule)

def parse_rule(line) : {Int32, Rule}
  s = StringScanner.new(line)

  s.scan(/(\d+): /)
  rule_num = s[1].to_i

  rule_parts = [] of Rule

  while (next_rule = s.scan_until(/( \| )|$/))
    if s[1]?
      # part of a union
      rule_parts << next_rule.chomp(s[1]).split(" ").map(&.to_i)
    else
      case next_rule
      when /"(\w)"/
        # single char
        rule_parts << $1.char_at(0)
      when .empty?
        # end of string
        break
      else
        # sequence of rules
        rule_parts << next_rule.split(" ").map(&.to_i)
      end
    end
  end

  if rule_parts.one?
    {rule_num, rule_parts[0]}
  else
    {rule_num, rule_parts}
  end
end

rules = {} of Int32 => Rule

rule_lines.each do |line|
  rule_num, rule = parse_rule(line)
  rules[rule_num] = rule
end

def regex_string(rule, rules) : String
  case rule
  when Char
    rule.to_s
  when Array(Int32)
    rule.map { |r| regex_string(rules[r], rules) }.join("")
  when Array(Rule)
    union_rules = rule.map { |r| regex_string(r, rules) }.join("|")
    "(?:#{union_rules})"
  else
    raise "asdf"
  end
end

# Part 1
main_rule = /^#{regex_string(rules[0], rules)}$/
puts data_lines.count(&.matches?(main_rule))

# Part 2
rule42 = regex_string(rules[42], rules)
rule31 = regex_string(rules[31], rules)

puts data_lines.count { |line|
  # Make sure rule 42 matches more times than rule 31
  match = line.match(/^((?:#{rule42})+)((?:#{rule31})+)$/)
  next false unless match

  rule42_count = match[1].scan(/#{rule42}/).size
  rule31_count = match[2].scan(/#{rule31}/).size

  rule42_count > rule31_count
}
