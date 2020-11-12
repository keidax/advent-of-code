# Needed to store a replacable global variable
class WireCache
  @@wires = Hash(String, Wire).new do |hash, key|
    hash[key] = Direct.new(key.to_u16)
  end

  def self.wires=(@@wires)
  end

  def self.wires
    @@wires
  end
end

abstract class Wire
  abstract def value : UInt16

  def wires
    WireCache.wires
  end
end

class Direct < Wire
  def_clone

  def initialize(@value : UInt16)
  end

  def value : UInt16
    @value
  end
end

class Refer < Wire
  def_clone

  def initialize(@a : String)
  end

  def value : UInt16
    wires[@a].value
  end
end

class And < Wire
  def_clone

  def initialize(@a : String, @b : String)
  end

  def value : UInt16
    # basic caching to avoid computing values more than once
    unless wires[@a].is_a? Direct
      wires[@a] = Direct.new(wires[@a].value)
    end
    unless wires[@b].is_a? Direct
      wires[@b] = Direct.new(wires[@b].value)
    end
    wires[@a].value & wires[@b].value
  end
end

class Or < Wire
  def_clone

  def initialize(@a : String, @b : String)
  end

  def value : UInt16
    unless wires[@a].is_a? Direct
      wires[@a] = Direct.new(wires[@a].value)
    end
    unless wires[@b].is_a? Direct
      wires[@b] = Direct.new(wires[@b].value)
    end
    wires[@a].value | wires[@b].value
  end
end

class Not < Wire
  def_clone

  def initialize(@a : String)
  end

  def value : UInt16
    ~wires[@a].value
  end
end

class LShift < Wire
  def_clone

  def initialize(@a : String, @shift : UInt16)
  end

  def value : UInt16
    wires[@a].value << @shift
  end
end

class RShift < Wire
  def_clone

  def initialize(@a : String, @shift : UInt16)
  end

  def value : UInt16
    wires[@a].value >> @shift
  end
end

# Part 1
File.each_line("input.txt") do |line|
  case line
  when /^(\d+) -> (\w+)/
    WireCache.wires[$2] = Direct.new($1.to_u16)
  when /^(\w+) -> (\w+)/
    WireCache.wires[$2] = Refer.new($1)
  when /(\w+) AND (\w+) -> (\w+)/
    WireCache.wires[$3] = And.new($1, $2)
  when /(\w+) OR (\w+) -> (\w+)/
    WireCache.wires[$3] = Or.new($1, $2)
  when /NOT (\w+) -> (\w+)/
    WireCache.wires[$2] = Not.new($1)
  when /(\w+) LSHIFT (\d+) -> (\w+)/
    WireCache.wires[$3] = LShift.new($1, $2.to_u16)
  when /(\w+) RSHIFT (\d+) -> (\w+)/
    WireCache.wires[$3] = RShift.new($1, $2.to_u16)
  else
    raise "unknown: #{line}"
  end
end

orig_wires = WireCache.wires.clone
a_value = WireCache.wires["a"].value
puts a_value

# Part 2
orig_wires["b"] = Direct.new(a_value)
WireCache.wires = orig_wires
puts WireCache.wires["a"].value
