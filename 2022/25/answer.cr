require "../aoc"

AOC.day!(25)

enum SnafuDigit
  DoubleMinus = -2
  Minus       = -1
  Zero        =  0
  One         =  1
  Two         =  2

  def self.from_char(c : Char)
    case c
    when '=' then DoubleMinus
    when '-' then Minus
    when '0' then Zero
    when '1' then One
    when '2' then Two
    else          raise "Unknown digit #{c}"
    end
  end

  def to_s : String
    case self
    in DoubleMinus then "="
    in Minus       then "-"
    in Zero        then "0"
    in One         then "1"
    in Two         then "2"
    end
  end
end

class SnafuNumber
  getter num : Int64

  def self.additive_identity
    new(0)
  end

  def initialize(@num)
  end

  def initialize(digits : Enumerable(SnafuDigit))
    @num = digits.reduce(0i64) do |acc, d|
      acc * 5 + d.value
    end
  end

  def +(other : self) : self
    SnafuNumber.new(self.num + other.num)
  end

  def to_s : String
    digits = [] of SnafuDigit

    remaining = @num
    rollover = 0

    while remaining > 0
      val = (remaining % 5).to_i + rollover

      if val <= 2
        digits << SnafuDigit.new(val)
        rollover = 0
      else
        digits << SnafuDigit.new(val - 5)
        rollover = 1
      end

      remaining //= 5
    end

    digits.reverse.join
  end
end

numbers = AOC.lines.map do |line|
  digits = line.chars.map { |c| SnafuDigit.from_char(c) }
  SnafuNumber.new(digits)
end

AOC.part1 do
  numbers.sum.to_s
end
