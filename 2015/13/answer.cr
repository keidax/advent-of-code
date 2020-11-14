HAPPINESS = Hash(String, Hash(String, Int32)).new do |hash, key|
  hash[key] = Hash(String, Int32).new do |inner_hash, inner_key|
    inner_hash[inner_key] = 0
  end
end

File.each_line("input.txt") do |line|
  line.match(/(\w+) would (\w+) (\d+) happiness units by sitting next to (\w+)./)
  net_happiness = if $2 == "lose"
                    -$3.to_i32
                  else
                    $3.to_i32
                  end

  HAPPINESS[$1][$4] += net_happiness
  HAPPINESS[$4][$1] += net_happiness
end

PEOPLE = Set(String).new(HAPPINESS.keys)

def find_happiest_order(seated : Array(String)) : Int32
  outcomes = [] of Int32
  last_seated = seated.last

  (PEOPLE - seated).each do |person|
    seated << person
    outcomes << (HAPPINESS[last_seated][person] + find_happiest_order(seated))
    seated.pop
  end

  return outcomes.max? || HAPPINESS[last_seated][seated.first]
end

# Part 1
puts(PEOPLE.map do |person|
  find_happiest_order([person])
end.max)

# Part 2
HAPPINESS.each do |person, combos|
  combos["Me"] = 0
end
HAPPINESS["Me"] = PEOPLE.to_h { |person| {person, 0} }
PEOPLE << "Me"

puts(PEOPLE.map do |person|
  find_happiest_order([person])
end.max)
