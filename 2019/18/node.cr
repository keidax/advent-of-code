require "colorize"

class Node
  property x : Int32, y : Int32
  property! key : Char?, door : Char?
  property? start : Bool

  def initialize(@x, @y, @key = nil, @door = nil, @start = false)
  end

  def intersection?
    !(key? || door? || start?)
  end

  def to_s(io)
    io << "#<Node: #{x.colorize(:blue)},#{y.colorize(:blue)} "
    if key?
      io << key.colorize(:green).bold
    elsif door?
      io << door.colorize(:red)
    elsif start?
      io << '@'.colorize(:magenta)
    else
      io << '+'.colorize(:red)
    end
    io << ">"
  end

  def inspect(io)
    to_s(io)
  end

  def_equals_and_hash x, y
end
