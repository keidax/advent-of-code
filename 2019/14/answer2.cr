alias Chemical = String

struct ChemAmt
  property chemical : Chemical, amount : Int64

  def self.parse(str : String) : self
    md = str.match(/(\d+) ([A-Z]+)/).not_nil!
    ChemAmt.new(md[2], md[1].to_i64)
  end

  def initialize(@chemical, @amount)
  end

  def +(other) : ChemAmt
    raise "chemicals don't match" unless other.chemical == self.chemical

    ChemAmt.new(chemical, self.amount + other.amount)
  end

  def -(other) : ChemAmt
    raise "chemicals don't match" unless other.chemical == self.chemical

    ChemAmt.new(chemical, self.amount - other.amount)
  end

  def *(mult) : ChemAmt
    ChemAmt.new(chemical, self.amount * mult)
  end
end

ORDER = {"ORE" => 0}

# ORE has an order of 0
# other chemicals have an order of 1 + the max order of input chemicals
def order(chem : Chemical) : Int32
  ORDER[chem] ||= 1 + REACTIONS[chem].inputs.map { |in| order(in.chemical) }.max
end

class Reaction
  property inputs : Array(ChemAmt), output : ChemAmt

  def initialize(str : String)
    inputs, output = str.split(" => ")
    @output = ChemAmt.parse output

    input_chems = inputs.split(", ")
    @inputs = input_chems.map &->ChemAmt.parse(String)
  end
end

REACTIONS = Hash(Chemical, Reaction).new

File.each_line("input.txt") do |line|
  reaction = Reaction.new(line)
  REACTIONS[reaction.output.chemical] = reaction
end

MAX_ORE = 1_000_000_000_000

def required_ore(fuel)
  required = [ChemAmt.new("FUEL", fuel)]

  until required.all? { |r| r.chemical == "ORE" }
    required = reduce_inputs(required)
  end

  required.first.amount
end

def reduce_inputs(required_inputs) : Array(ChemAmt)
  new_inputs = [] of ChemAmt

  required_inputs.each do |required|
    new_inputs.concat(reduce_lossless(required))
  end

  if new_inputs == required_inputs
    new_inputs = reduce_wasteful(new_inputs)
  end

  compress(new_inputs)
end

def reduce_lossless(required) : Array(ChemAmt)
  return [required] if required.chemical == "ORE" # Can't reduce further

  reaction = REACTIONS[required.chemical]

  if reaction.output.amount <= required.amount
    count = required.amount // reaction.output.amount
    remainder = required - reaction.output * count
    [remainder].concat(reaction.inputs.map { |in| in * count })
  else
    [required]
  end
end

def reduce_wasteful(required_inputs : Array(ChemAmt)) : Array(ChemAmt)
  max_order = required_inputs.map { |in| order(in.chemical) }.max

  highest_order_input = required_inputs.find { |in| order(in.chemical) == max_order }.not_nil!
  required_inputs.delete(highest_order_input)

  required_inputs.concat REACTIONS[highest_order_input.chemical].inputs
end

def compress(chemicals) : Array(ChemAmt)
  all_amounts = Hash(Chemical, Int64).new(initial_capacity: chemicals.size)

  chemicals.reduce(all_amounts) do |h, chem|
    next h if chem.amount <= 0

    h[chem.chemical] ||= 0
    h[chem.chemical] += chem.amount
    h
  end

  all_amounts.map &->ChemAmt.new(Chemical, Int64)
end

fuel = 1_i64

loop do
  ore = required_ore(fuel)

  break if ore > MAX_ORE
  fuel *= 2
end

range = (fuel//2..fuel)

puts bin_search(range)

def bin_search(range)
  if range.begin == range.end
    return range.begin
  end

  mid = (range.begin + range.end) // 2
  if required_ore(mid) > MAX_ORE
    return bin_search(range.begin..(mid - 1))
  else
    return bin_search(mid..range.end)
  end
end
