class Field
  property name : String
  property ranges : Array(Range(Int32, Int32))

  def initialize(@name, @ranges)
  end

  def valid?(value : Int32)
    ranges.any? &.includes?(value)
  end

  def valid?(values : Array(Int32))
    values.all? { |value| valid?(value) }
  end
end

lines = File.read_lines("input.txt")
fields = [] of Field
valid_tickets = [] of Array(Int32)
my_ticket = [] of Int32

sections = lines
  .chunks(&.blank?)
  .reject! { |blank, _| blank }
  .map { |_, lines| lines }

field_section = sections[0]
my_ticket_section = sections[1][1..-1]
other_tickets_section = sections[2][1..-1]

field_section.each do |field_string|
  field_string =~ /(.*): (\d+)-(\d+) or (\d+)-(\d+)/

  fields << Field.new(
    name: $1,
    ranges: [($2.to_i..$3.to_i), ($4.to_i..$5.to_i)]
  )
end

my_ticket = my_ticket_section[0].split(",").map(&.to_i)

# Part 1
error_rate = 0

other_tickets_section.each do |other_ticket|
  ticket = other_ticket.split(",").map(&.to_i)

  valid = true

  ticket.each do |value|
    unless fields.any? &.valid?(value)
      valid = false
      error_rate += value
    end
  end

  if valid
    valid_tickets << ticket
  end
end

puts error_rate

# Part 2
possible_positions_for_field = {} of Field => Array(Int32)
field_to_position = {} of Field => Int32

positions = (valid_tickets + [my_ticket]).transpose.map_with_index do |values, i|
  {i, values}
end

while positions.any?
  possible_positions_for_field.clear

  positions.each do |i, values|
    fields.each do |field|
      if field.valid?(values)
        possible_positions_for_field[field] ||= [] of Int32
        possible_positions_for_field[field] << i
      end
    end
  end

  possible_positions_for_field.each do |field, possible_positions|
    if possible_positions.one?
      position = possible_positions[0]
      field_to_position[field] = position

      fields.delete(field)
      positions.reject! { |i, _| i == position }
    end
  end
end

departure_val = 1_i64
field_to_position.each do |field, pos|
  if field.name.matches? /departure/
    departure_val *= my_ticket[pos]
  end
end

puts departure_val
