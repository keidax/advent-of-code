require_relative "aoc"

input = AOC.day(13)

class ClawMachine
  attr_accessor :ax, :ay
  attr_accessor :bx, :by
  attr_accessor :x, :y

  def initialize(lines)
    lines.each do |line|
      case line
      when /Button A: X\+(\d+), Y\+(\d+)/
        self.ax = $1.to_r
        self.ay = $2.to_i
      when /Button B: X\+(\d+), Y\+(\d+)/
        self.bx = $1.to_r
        self.by = $2.to_r
      when /Prize: X=(\d+), Y=(\d+)/
        self.x = $1.to_r
        self.y = $2.to_r
      end
    end
  end

  def tokens_to_win
    b = solve_b
    a = solve_a(b)

    if a.denominator == 1 && b.denominator == 1
      # both integers, so we have a valid solution
      (a * 3 + b).to_i
    else
      0
    end
  end

  private

  def solve_b
    (@y - (@x * @ay / @ax)) / (@by - (@bx * @ay / @ax))
  end

  def solve_a(b)
    (@x - @bx * b) / @ax
  end
end

claw_machines = input.line_sections.map { ClawMachine.new _1 }

AOC.part1 do
  claw_machines.sum(&:tokens_to_win)
end

AOC.part2 do
  claw_machines.each do |m|
    m.x += 10000000000000
    m.y += 10000000000000
  end

  claw_machines.sum(&:tokens_to_win)
end
