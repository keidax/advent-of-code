rules = Hash(String, Hash(String, Int32)).new

File.each_line("input.txt") do |line|
  case line
  when /(\w+ \w+) bags contain no other bags./
    rules[$1] = {} of String => Int32
  when /(\w+ \w+) bags contain (.+)./
    rules[$1] = rule = {} of String => Int32
    inner_bags = $2.split(", ")

    inner_bags.each do |bag|
      bag =~ /(\d+) (\w+ \w+) bags?/
      rule[$2] = $1.to_i
    end
  end
end

# Part 1

def all_bags_containing(bag_type, rules)
  searched_outer_bags = Set(String).new
  unsearched_outer_bags = Set(String).new
  inner_bags = Set(String){bag_type}

  while inner_bags.any?
    # Consider bags we searched already to be done
    searched_outer_bags.concat(unsearched_outer_bags)
    unsearched_outer_bags.clear

    # Look for bags containing any of the inner bag types
    rules.each do |outer_bag, inner_bag_rules|
      inner_bag_rules.each do |inner_bag, _|
        if inner_bags.includes?(inner_bag)
          unsearched_outer_bags << outer_bag
        end
      end
    end

    # Set the new inner bag types
    unsearched_outer_bags -= searched_outer_bags
    inner_bags = unsearched_outer_bags.dup
  end

  searched_outer_bags
end

puts all_bags_containing("shiny gold", rules).size

# Part 2

def find_bags_inside(bag_type, rules) : Int32
  inner_bags = rules[bag_type]
  inner_bags.map do |inner_bag_type, count|
    (find_bags_inside(inner_bag_type, rules) + 1) * count
  end.sum
end

puts find_bags_inside("shiny gold", rules)
