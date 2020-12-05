class Spell
  getter mana : Int32
  @action : GameState ->
  getter! effect : Effect?

  def initialize(@mana, @effect : Effect? = nil, &@action : GameState ->)
  end

  def castable?(state : GameState) : Bool
    # Player must have enough mana
    return false if self.mana > state.player_mana

    # Spells without effects have no cooldown
    return true if !self.effect?

    # Spells with effects can't be stacked
    timer = state.effects[self.effect]?
    timer == nil
  end

  def cast(state)
    state.player_mana -= self.mana
    state.total_mana_spent += self.mana
    @action.call(state)
  end
end

enum Effect
  Shield
  Poison
  Recharge
end

SPELLS = [
  # Magic Missile
  Spell.new(mana: 53) do |state|
    state.boss_hp -= 4
  end,
  # Drain
  Spell.new(mana: 73) do |state|
    state.boss_hp -= 2
    state.player_hp += 2
  end,
  # Shield
  Spell.new(mana: 113, effect: :shield) do |state|
    state.effects[Effect::Shield] = 6
  end,
  # Poison
  Spell.new(mana: 173, effect: :poison) do |state|
    state.effects[Effect::Poison] = 6
  end,
  # Recharge
  Spell.new(mana: 229, effect: :recharge) do |state|
    state.effects[Effect::Recharge] = 5
  end,
]

class GameState
  property player_hp : Int32 = 50
  property player_mana : Int32 = 500
  property total_mana_spent : Int32 = 0
  property? player_turn : Bool = true
  property health_drain : Int32 = 0

  property boss_hp : Int32 = 71
  property boss_damage : Int32 = 10

  property effects : Hash(Effect, Int32) = {} of Effect => Int32

  def_clone
end

def find_least_mana(state : GameState) : Int32
  if state.player_turn?
    state.player_hp -= state.health_drain
    if state.player_hp <= 0
      return Int32::MAX
    end
  end

  if state.effects[Effect::Poison]?
    state.boss_hp -= 3

    if state.boss_hp <= 0
      return state.total_mana_spent
    end
  end

  if state.effects[Effect::Recharge]?
    state.player_mana += 101
  end

  # Count down effects
  state.effects.each do |effect, time_left|
    if time_left <= 1
      state.effects.delete(effect)
    else
      state.effects[effect] = time_left - 1
    end
  end

  if state.player_turn?
    possible_spells = SPELLS.select &.castable?(state)

    if possible_spells.empty?
      return Int32::MAX
    end

    outcomes = possible_spells.map do |pos_spell|
      new_state = state.clone
      pos_spell.cast(new_state)
      new_state.player_turn = false

      if new_state.boss_hp <= 0
        new_state.total_mana_spent
      else
        find_least_mana(new_state)
      end
    end

    outcomes.min
  else
    damage = boss_damage(state)
    state.player_hp -= damage
    state.player_turn = true

    if state.player_hp <= 0
      Int32::MAX
    else
      find_least_mana(state)
    end
  end
end

def boss_damage(state)
  armor = 0
  if state.effects[Effect::Shield]?
    armor = 7
  end

  boss_damage = state.boss_damage - armor
  boss_damage = 1 if boss_damage < 1
  boss_damage
end

# Part 1
state = GameState.new
puts find_least_mana(state)

# Part 2
state = GameState.new
state.health_drain = 1
puts find_least_mana(state)
