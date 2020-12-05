alias Item = {cost: Int32, damage: Int32, armor: Int32}

WEAPONS = [
  {cost: 8, damage: 4, armor: 0},
  {cost: 10, damage: 5, armor: 0},
  {cost: 25, damage: 6, armor: 0},
  {cost: 40, damage: 7, armor: 0},
  {cost: 74, damage: 8, armor: 0},
]

ARMOR = [
  {cost: 0, damage: 0, armor: 0}, # no armor
  {cost: 0, damage: 0, armor: 0},
  {cost: 13, damage: 0, armor: 1},
  {cost: 31, damage: 0, armor: 2},
  {cost: 53, damage: 0, armor: 3},
  {cost: 75, damage: 0, armor: 4},
  {cost: 102, damage: 0, armor: 5},
]

RINGS = [
  {cost: 0, damage: 0, armor: 0}, # no ring
  {cost: 0, damage: 0, armor: 0}, # no ring
  {cost: 25, damage: 1, armor: 0},
  {cost: 50, damage: 2, armor: 0},
  {cost: 100, damage: 3, armor: 0},
  {cost: 20, damage: 0, armor: 1},
  {cost: 40, damage: 0, armor: 2},
  {cost: 80, damage: 0, armor: 3},
]

class Fighter
  getter hp : Int32
  getter damage : Int32
  getter armor : Int32

  def initialize(@hp, @damage, @armor)
  end

  def take_damage(damage : Int32)
    damage = damage - @armor
    damage = 1 if damage < 1

    @hp -= damage
    @hp = 0 if @hp < 0
  end
end

def can_beat_boss?(items : Array(Item)) : Bool
  player = Fighter.new(hp: 100, damage: items.sum(&.[:damage]), armor: items.sum(&.[:armor]))
  boss = Fighter.new(hp: 100, damage: 8, armor: 2)

  attacker = player
  defender = boss

  while player.hp > 0 && boss.hp > 0
    defender.take_damage(attacker.damage)
    attacker, defender = defender, attacker
  end

  return player.hp > 0
end

# Part 1
min_gold = 9999
items = [] of Item
WEAPONS.each do |weapon|
  items << weapon
  ARMOR.each do |armor|
    items << armor
    RINGS.combinations(2).each do |rings|
      items.concat(rings)

      if can_beat_boss?(items)
        min_gold = [min_gold, items.sum &.[:cost]].min
      end

      items.pop(2)
    end
    items.pop
  end
  items.pop
end

pp min_gold

# Part 2
max_gold = 0
items = [] of Item
WEAPONS.each do |weapon|
  items << weapon
  ARMOR.each do |armor|
    items << armor
    RINGS.combinations(2).each do |rings|
      items.concat(rings)

      if !can_beat_boss?(items)
        max_gold = [max_gold, items.sum &.[:cost]].max
      end

      items.pop(2)
    end
    items.pop
  end
  items.pop
end
pp max_gold
