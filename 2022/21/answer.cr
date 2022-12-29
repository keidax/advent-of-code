require "../aoc"

AOC.day!(21)

abstract class Monkey
  property name : String

  def initialize(@name)
  end

  def self.build(line) : Monkey
    name = line[0..3]

    case line[6..]
    when /(\d+)/
      NumberMonkey.new(name, $1.to_i64)
    when /(\w+) \+ (\w+)/
      AddMonkey.new(name, $1, $2)
    when /(\w+) - (\w+)/
      SubtractMonkey.new(name, $1, $2)
    when /(\w+) \* (\w+)/
      MultiplyMonkey.new(name, $1, $2)
    when /(\w+) \/ (\w+)/
      DivideMonkey.new(name, $1, $2)
    else
      raise "could not parse #{line}"
    end
  end

  abstract def get_number
  abstract def find_missing_number(target)
end

class NumberMonkey < Monkey
  property num : Int64

  def initialize(@name, @num)
  end

  def get_number
    num
  end

  def can_resolve?
    true
  end

  def find_missing_number(target)
    raise "should not reach here"
  end
end

abstract class OperationMonkey < Monkey
  property a_name : String, b_name : String

  def initialize(@name, @a_name, @b_name)
  end

  def a
    MONKEYS[@a_name]
  end

  def b
    MONKEYS[@b_name]
  end

  def can_resolve?
    a.can_resolve? && b.can_resolve?
  end
end

class AddMonkey < OperationMonkey
  def get_number
    a.get_number + b.get_number
  end

  def find_missing_number(target)
    if a.can_resolve?
      b.find_missing_number(target - a.get_number)
    else
      a.find_missing_number(target - b.get_number)
    end
  end
end

class SubtractMonkey < OperationMonkey
  def get_number
    a.get_number - b.get_number
  end

  def find_missing_number(target)
    if a.can_resolve?
      b.find_missing_number(a.get_number - target)
    else
      a.find_missing_number(b.get_number + target)
    end
  end
end

class MultiplyMonkey < OperationMonkey
  def get_number
    a.get_number * b.get_number
  end

  def find_missing_number(target)
    if a.can_resolve?
      b.find_missing_number(target // a.get_number)
    else
      a.find_missing_number(target // b.get_number)
    end
  end
end

class DivideMonkey < OperationMonkey
  def get_number
    a.get_number // b.get_number
  end

  def find_missing_number(target)
    if a.can_resolve?
      b.find_missing_number(a.get_number // target)
    else
      a.find_missing_number(target * b.get_number)
    end
  end
end

class HumanMonkey < Monkey
  def initialize(@name)
  end

  def get_number
    raise "can't get number"
  end

  def can_resolve?
    false
  end

  def find_missing_number(target)
    target
  end
end

class RootMonkey < OperationMonkey
  def get_number
    raise "can't get number"
  end

  def find_missing_number(target = 0)
    if a.can_resolve?
      target = a.get_number
      b.find_missing_number(target)
    else
      target = b.get_number
      a.find_missing_number(target)
    end
  end
end

MONKEYS = {} of String => Monkey

AOC.each_line do |line|
  monkey = Monkey.build(line)
  MONKEYS[monkey.name] = monkey
end

AOC.part1 do
  MONKEYS["root"].get_number
end

AOC.part2 do
  MONKEYS["humn"] = HumanMonkey.new("humn")

  root = MONKEYS["root"].as(OperationMonkey)
  new_root = RootMonkey.new("root", root.a_name, root.b_name)
  MONKEYS["root"] = new_root

  new_root.find_missing_number
end
