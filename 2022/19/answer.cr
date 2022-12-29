require "../aoc"

AOC.day!(19)

class Recipe
  property id : Int32
  property ore_robot : {ore: Int32}
  property clay_robot : {ore: Int32}
  property obsidian_robot : {ore: Int32, clay: Int32}
  property geode_robot : {ore: Int32, obsidian: Int32}

  property max_ore : Int32

  property state_cache = {} of State => Int32

  struct State
    property ore = 0u16
    property clay = 0u16
    property obsidian = 0u16
    property geodes = 0u16

    property ore_robots = 0u8
    property clay_robots = 0u8
    property obsidian_robots = 0u8
    property geode_robots = 0u8
  end

  def initialize(@id, @ore_robot, @clay_robot, @obsidian_robot, @geode_robot)
    # Determine the max number of ore robots we need based on our recipe.
    # We can build at most one robot every minute, so we won't need more than max_ore ore robots.
    @max_ore = [ore_robot[:ore], clay_robot[:ore], obsidian_robot[:ore], geode_robot[:ore]].max
  end

  def build_geode_robot?(state)
    state.ore >= geode_robot[:ore] && state.obsidian >= geode_robot[:obsidian]
  end

  def build_obsidian_robot?(minutes, state)
    # If there are only 3 minutes left, it doesn't make sense to build a new obsidian bot. It takes
    # 1 minute to build the bot
    # 1 minute to harvest one extra obsidian
    # 1 minute to use the extra obsidian to build a new geode bot
    # at which point the geode bot has no time to harvest any geodes.
    minutes > 3 &&
      state.obsidian_robots < geode_robot[:obsidian] &&
      state.ore >= obsidian_robot[:ore] && state.clay >= obsidian_robot[:clay]
  end

  def build_clay_robot?(minutes, state)
    minutes > 5 &&
      state.clay_robots < obsidian_robot[:clay] &&
      state.ore >= clay_robot[:ore]
  end

  def build_ore_robot?(minutes, state)
    minutes > 7 &&
      state.ore_robots < max_ore &&
      state.ore >= ore_robot[:ore]
  end

  def build_nothing(state)
    state.ore += state.ore_robots
    state.clay += state.clay_robots
    state.obsidian += state.obsidian_robots
    state.geodes += state.geode_robots

    state
  end

  def build_ore_robot(state)
    state = build_nothing(state)
    state.ore -= ore_robot[:ore]
    state.ore_robots += 1

    state
  end

  def build_clay_robot(state)
    state = build_nothing(state)
    state.ore -= clay_robot[:ore]
    state.clay_robots += 1

    state
  end

  def build_obsidian_robot(state)
    state = build_nothing(state)
    state.ore -= obsidian_robot[:ore]
    state.clay -= obsidian_robot[:clay]
    state.obsidian_robots += 1

    state
  end

  def build_geode_robot(state)
    state = build_nothing(state)
    state.ore -= geode_robot[:ore]
    state.obsidian -= geode_robot[:obsidian]
    state.geode_robots += 1

    state
  end

  def max_geodes(minutes)
    state = State.new
    state.ore_robots = 1

    max_geodes(minutes, state).not_nil!.to_i32
  end

  def max_geodes(minutes, state : State)
    if (prev_best = state_cache[state]?)
      # We've reached this state before, nothing left to explore
      return if prev_best >= minutes
    end

    state_cache[state] = minutes

    if minutes == 0
      return state.geodes
    end

    if build_geode_robot?(state)
      state = build_geode_robot(state)
      max_geodes(minutes - 1, state)
    else
      max = 0

      # This would look nicer using an array, but it's faster to avoid allocating
      # objects in a loop.

      if build_obsidian_robot?(minutes, state)
        res = max_geodes(minutes - 1, build_obsidian_robot(state))

        if res && res > max
          max = res
        end
      end

      if build_clay_robot?(minutes, state)
        res = max_geodes(minutes - 1, build_clay_robot(state))

        if res && res > max
          max = res
        end
      end

      if build_ore_robot?(minutes, state)
        res = max_geodes(minutes - 1, build_ore_robot(state))
        if res && res > max
          max = res
        end
      end

      res = max_geodes(minutes - 1, build_nothing(state))
      if res && res > max
        max = res
      end

      max
    end
  end
end

recipes = AOC.lines.map do |line|
  line =~ /Blueprint (\d+):/
  id = $1.to_i

  line =~ /Each ore robot costs (\d+) ore/
  ore_robot = {ore: $1.to_i}

  line =~ /Each clay robot costs (\d+) ore/
  clay_robot = {ore: $1.to_i}

  line =~ /Each obsidian robot costs (\d+) ore and (\d+) clay/
  obsidian_robot = {ore: $1.to_i, clay: $2.to_i}

  line =~ /Each geode robot costs (\d+) ore and (\d+) obsidian/
  geode_robot = {ore: $1.to_i, obsidian: $2.to_i}

  Recipe.new(id, ore_robot, clay_robot, obsidian_robot, geode_robot)
end

AOC.part1 do
  recipes.map { |r| r.max_geodes(24) * r.id }.sum
end

AOC.part2 do
  c = Channel(Int32).new
  recipes[0..2]
    .map { |recipe| spawn { c.send recipe.max_geodes(32) } }
    .map { c.receive }
    .product
end
