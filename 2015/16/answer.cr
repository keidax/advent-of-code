{% begin %}
{% compounds = %w[children cats samoyeds pomeranians akitas vizslas goldfish trees cars perfumes] %}

class Sue
  getter number : Int32

  {% for c in compounds %}
  getter {{c.id}} : Int32?
  {% end %}

  def initialize(
    @number,
    {% for c in compounds %}
    @{{c.id}},
    {% end %}
  )
  end
end

aunts = [] of Sue

File.each_line("input.txt") do |line|
  number = line.match(/Sue (\d+):/).not_nil![1].to_i32
  {% for c in compounds %}
    num_{{c.id}} = line.match(/{{c.id}}: (\d+)/).try { |match| match[1].to_i32 }
  {% end %}

  aunts << Sue.new(number, {% for c in compounds %} num_{{c.id}}, {% end %})
end

# Part 1
criteria = {
  children:    3,
  cats:        7,
  samoyeds:    2,
  pomeranians: 3,
  akitas:      0,
  vizslas:     0,
  goldfish:    5,
  trees:       3,
  cars:        3,
  perfumes:    1,
}

aunts.each do |aunt|
  {% for c in compounds %}

    if aunt.{{c.id}}
      next unless aunt.{{c.id}} == criteria[{{c}}]
    end

  {% end %}
  puts aunt.number
end

# Part 2
criteria = {
  children:    3..3,
  cats:        8..,
  samoyeds:    2..2,
  pomeranians: 0...3,
  akitas:      0..0,
  vizslas:     0..0,
  goldfish:    0...5,
  trees:       4..,
  cars:        3..3,
  perfumes:    1..1,
}

aunts.each do |aunt|
  {% for c in compounds %}

    if aunt.{{c.id}}
      next unless criteria[{{c}}].includes? aunt.{{c.id}}.not_nil!
    end

  {% end %}
  puts aunt.number
end
{% end %}
