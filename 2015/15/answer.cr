class Ingredient
  getter \
    capacity : Int64,
    durability : Int64,
    flavor : Int64,
    texture : Int64,
    calories : Int64

  def initialize(
    @capacity,
    @durability,
    @flavor,
    @texture,
    @calories
  )
  end

  def self.score(amounts : Hash(Ingredient, Int32)) : Int64
    capacity = 0_i64
    durability = 0_i64
    flavor = 0_i64
    texture = 0_i64

    amounts.each do |ingredient, amount|
      capacity += ingredient.capacity * amount
      durability += ingredient.durability * amount
      flavor += ingredient.flavor * amount
      texture += ingredient.texture * amount
    end

    capacity = 0_i64 if capacity < 0
    durability = 0_i64 if durability < 0
    flavor = 0_i64 if flavor < 0
    texture = 0_i64 if texture < 0

    capacity * durability * flavor * texture
  end

  def self.calories(amounts : Hash(Ingredient, Int32)) : Int64
    amounts.sum { |ingredient, amount| ingredient.calories * amount }.to_i64
  end
end

ingredients = {} of Ingredient => Int32

File.each_line("input.txt") do |line|
  line.match /\w+: capacity ([-\d]+), durability ([-\d]+), flavor ([-\d]+), texture ([-\d]+), calories ([-\d]+)/
  ingredients[Ingredient.new($1.to_i64, $2.to_i64, $3.to_i64, $4.to_i64, $5.to_i64)] = 1
end

tsps = ingredients.values.sum

# Part 1
while tsps < 100
  best_to_add = ingredients.max_by do |ingredient, _|
    with_added = ingredients.dup
    with_added[ingredient] += 1
    Ingredient.score(with_added)
  end[0]

  ingredients[best_to_add] += 1
  tsps += 1
end

puts Ingredient.score(ingredients)

# Part 2
ingredient_list = ingredients.keys
ingredients.each do |ingredient, _|
  ingredients[ingredient] = 0
end

def solve_for_ingredient(list, curr_index, amounts) : Int64
  if curr_index + 1 == list.size
    # This is the final ingredient
    amounts[list[curr_index]] = 0
    amount = 100 - amounts.values.sum
    return 0_i64 if amount < 0

    amounts[list[curr_index]] = amount
    return 0_i64 if Ingredient.calories(amounts) != 500

    score = Ingredient.score(amounts)
    return score
  else
    (0..100).map do |i|
      amounts[list[curr_index]] = i
      solve_for_ingredient(list, curr_index + 1, amounts)
    end.max
  end
end

pp solve_for_ingredient(ingredient_list, 0, ingredients)
