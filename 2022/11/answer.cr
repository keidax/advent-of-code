require "../aoc"

AOC.day!(11)

class Monkey
  property items : Array(Int64)
  property operation : Int64 -> Int64
  property divisor : Int64
  property true_monkey : Int64
  property false_monkey : Int64

  property total_items_inspected : Int64 = 0

  def self.create(lines) : self
    items = lines[1]
      .strip
      .lchop("Starting items: ")
      .split(", ")
      .map(&.to_i64)

    formula = lines[2]
      .strip
      .lchop("Operation: new = ")
      .split(" ")

    a, op, b = formula
    a = a.to_i64?
    b = b.to_i64?

    operation = ->(i : Int64) do
      # if either arg was is "old", it will be nil here, so `i` gets used
      arg1 = a || i
      arg2 = b || i

      if op == "+"
        arg1 + arg2
      elsif op == "*"
        arg1 * arg2
      else
        raise "could not parse #{formula}"
      end
    end

    divisor = lines[3]
      .strip
      .lchop("Test: divisible by ")
      .to_i64

    true_monkey = lines[4]
      .strip
      .lchop("If true: throw to monkey ")
      .to_i64

    false_monkey = lines[5]
      .strip
      .lchop("If false: throw to monkey ")
      .to_i64

    Monkey.new(
      items: items,
      operation: operation,
      divisor: divisor,
      true_monkey: true_monkey,
      false_monkey: false_monkey,
    )
  end

  def initialize(@items, @operation, @divisor, @true_monkey, @false_monkey)
  end

  def inspect_items
    inspected_items = @items.map do |item|
      @total_items_inspected += 1

      worry_level = item
      worry_level = @operation.call(worry_level)
      worry_level = yield worry_level

      if worry_level % @divisor == 0
        {@true_monkey, worry_level}
      else
        {@false_monkey, worry_level}
      end
    end

    @items.clear

    inspected_items
  end

  def clone
    self.class.new(@items.clone, @operation, @divisor, @true_monkey, @false_monkey)
  end
end

orig_monkeys = AOC
  .lines
  .chunks { |line| line == "" }
  .map { |blank, lines| lines unless blank }
  .compact
  .map { |lines| Monkey.create(lines) }

def do_round(monkeys)
  monkeys.each do |monkey|
    items = monkey.inspect_items { |i| yield i }

    items.each do |target_monkey, item|
      monkeys[target_monkey].items << item
    end
  end
end

AOC.part1 do
  monkeys = orig_monkeys.clone
  20.times { do_round(monkeys) { |worry| worry // 3 } }

  inspect_counts = monkeys.map(&.total_items_inspected).sort
  inspect_counts[-2..-1].product
end

AOC.part2 do
  monkeys = orig_monkeys.clone
  lcm = monkeys.map(&.divisor).product
  # In order to keep the worry level reasonably low, use the LCM of all
  # divisors as the modulus
  10000.times { do_round(monkeys) { |worry| worry % lcm } }

  inspect_counts = monkeys.map(&.total_items_inspected).sort
  inspect_counts[-2..-1].product
end
