alias Chemical = String

struct ChemAmt
  property chemical : Chemical, amount : Int32

  def self.parse(str : String) : self
    md = str.match(/(\d+) ([A-Z]+)/).not_nil!
    ChemAmt.new(md[2], md[1].to_i)
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
end

# ORE has an order of 0
# other chemicals have an order of 1 + the max order of input chemicals
def order(chem : Chemical, reactions) : Int32
  return 0 if chem == "ORE"
  1 + reactions[chem].inputs.map { |in| order(in.chemical, reactions) }.max
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

reactions = Hash(Chemical, Reaction).new

File.each_line("input.txt") do |line|
  reaction = Reaction.new(line)
  reactions[reaction.output.chemical] = reaction
end

required = [ChemAmt.new("FUEL", 1)]

until required.all? { |r| r.chemical == "ORE" }
  required = reduce_inputs(required, reactions)
end

puts required.first.amount

def reduce_inputs(required_inputs, reactions) : Array(ChemAmt)
  new_inputs = [] of ChemAmt

  required_inputs.each do |required|
    new_inputs.concat(reduce_lossless(required, reactions))
  end

  if new_inputs == required_inputs
    new_inputs = reduce_wasteful(new_inputs, reactions)
  end

  compress(new_inputs)
end

def reduce_lossless(required, reactions) : Array(ChemAmt)
  return [required] if required.chemical == "ORE" # Can't reduce further

  reaction = reactions[required.chemical]

  if reaction.output.amount <= required.amount
    remainder = required - reaction.output
    [remainder].concat(reaction.inputs)
  else
    [required]
  end
end

def reduce_wasteful(required_inputs : Array(ChemAmt), reactions) : Array(ChemAmt)
  max_order = required_inputs.map { |in| order(in.chemical, reactions) }.max

  highest_order_input = required_inputs.find { |in| order(in.chemical, reactions) == max_order }.not_nil!
  required_inputs.delete(highest_order_input)

  required_inputs.concat reactions[highest_order_input.chemical].inputs
end

def compress(chemicals) : Array(ChemAmt)
  all_amounts = Hash(Chemical, Int32).new(chemicals.size)

  chemicals.reduce(all_amounts) do |h, chem|
    next h if chem.amount <= 0

    h[chem.chemical] ||= 0
    h[chem.chemical] += chem.amount
    h
  end

  all_amounts.map &->ChemAmt.new(Chemical, Int32)
end
