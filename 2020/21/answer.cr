foods = [] of {Set(String), Set(String)}

all_allergens = Hash(String, Set(String)).new

File.each_line("input.txt") do |line|
  line =~ /(.*) \(contains (.*)\)/
  ingredients = $1.split(" ").to_set
  allergens = $2.split(", ").to_set

  foods << {ingredients, allergens}
  allergens.each do |allergen|
    all_allergens[allergen] ||= ingredients
    all_allergens[allergen] &= ingredients
  end
end

while all_allergens.each_value.any? { |list| list.size > 1 }
  all_allergens.each do |allergen, foods|
    if foods.one?
      all_allergens.each do |other_allergen, other_foods|
        next if allergen == other_allergen

        all_allergens[other_allergen] = other_foods - foods
      end
    end
  end
end

# Part 1
dangerous_ingredients = all_allergens.values.reduce { |acc, foods| acc + foods }
puts foods.sum { |ingredients, _| (ingredients - dangerous_ingredients).size }

# Part 2
puts all_allergens.to_a
  .sort_by { |allergen, _| allergen }
  .map { |_, ingredients| ingredients.first }
  .join(",")
