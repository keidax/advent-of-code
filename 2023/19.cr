require "./aoc"

AOC.day!(19)

alias Rule = String | {String, Symbol, Int32, String}
alias Workflow = Array(Rule)

alias Part = {x: Int32, m: Int32, a: Int32, s: Int32}
alias Combo = Range(Int32, Int32)
alias PartCombo = {x: Combo, m: Combo, a: Combo, s: Combo}

def parse_workflow(line)
  line.match!(/(\w+){(.+)}/)

  name = $~[1]
  rules = $~[2].split(",").map do |rule_str|
    case rule_str
    when /(\w+)>(\d+):(\w+)/
      {$~[1], :gt, $~[2].to_i, $~[3]}
    when /(\w+)<(\d+):(\w+)/
      {$~[1], :lt, $~[2].to_i, $~[3]}
    when /^\w+$/
      $~[0]
    else
      raise "bad rule: #{rule_str}"
    end
  end

  {name, rules}
end

def parse_part(line)
  line.match!(/{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}/)
  {x: $~[1].to_i, m: $~[2].to_i, a: $~[3].to_i, s: $~[4].to_i}
end

def accepted?(workflows : Hash(String, Workflow), part)
  workflow = "in"

  loop do
    workflow = process_part(workflows[workflow], part)

    if workflow == "A"
      return true
    elsif workflow == "R"
      return false
    end
  end
end

def process_part(workflow : Workflow, part : Part) : String
  workflow.each do |rule|
    return rule if rule.is_a?(String)

    category, op, value, destination = rule

    if op == :lt
      if part[category] < value
        return destination
      end
    else
      if part[category] > value
        return destination
      end
    end
  end

  raise "failed to match any rules"
end

def acceptable_ranges(workflows : Hash(String, Workflow), current_wf, combo : PartCombo) : Array(PartCombo)
  if current_wf == "A"
    return [combo]
  elsif current_wf == "R"
    return [] of PartCombo
  end

  good_combos = [] of PartCombo

  workflows[current_wf].each do |rule|
    if rule.is_a?(String)
      good_combos.concat(acceptable_ranges(workflows, rule, combo))
      break
    end

    rule_match_combo, combo = apply_rule(rule, combo)
    rule_destination = rule[3]

    good_combos.concat(acceptable_ranges(workflows, rule_destination, rule_match_combo))
  end

  good_combos
end

# Split a part combination into 2 combinations: the parts that match the rule,
# and the parts that don't.
def apply_rule(rule, combo : PartCombo) : {PartCombo, PartCombo}
  category, op, value, destination = rule

  match = {} of String => Combo
  not_match = {} of String => Combo

  combo.each do |k, range|
    k = k.to_s

    if k != category
      match[k] = range
      not_match[k] = range
      next
    end

    unless combo[category].covers?(value)
      # The puzzle input seems to be structured so that whenever a rule is applied,
      # the set of combinations that match and the set of combinations that don't match
      # are both non-empty.
      raise "range of #{combo[category]} doesn't include #{value}"
    end

    if op == :lt
      match[k] = range.begin..(value - 1)
      not_match[k] = value..range.end
    else # :gt
      match[k] = (value + 1)..range.end
      not_match[k] = range.begin..value
    end
  end

  {PartCombo.from(match), PartCombo.from(not_match)}
end

def rating(part : Part)
  part.values.sum
end

def combo_size(combo : PartCombo)
  combo.values.map(&.size).map(&.to_i64).product
end

workflow_input, part_input = AOC.sections

workflows = workflow_input.map { |wf_line| parse_workflow(wf_line) }.to_h
parts = part_input.map { |part_line| parse_part(part_line) }

AOC.part1 do
  parts
    .select { |part| accepted?(workflows, part) }
    .sum { |part| rating(part) }
end

AOC.part2 do
  full_range = {x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000}

  acceptable_ranges(workflows, "in", full_range)
    .sum { |combo| combo_size(combo) }
end
