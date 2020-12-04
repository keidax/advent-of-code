class Passport
  {% begin %}
  {% properties = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"] %}

  {% for prop in properties %}
    property {{prop.id}} : String?
  {% end %}

  def initialize(
    {% for prop in properties %}
     @{{prop.id}} = nil,
    {% end %}
  )
  end

  def self.build_from_string(input : String) : self
    passport = Passport.new

    fields = input.split(/\s+/)
    fields.each do |field|
      parts = field.split(":")
      key, value = parts.first, parts.last

      case key
        {% for prop in properties %}
          when {{prop}} then passport.{{prop.id}} = value
        {% end %}
      end
    end

    passport
  end
  {% end %}

  def has_all_fields?
    byr && iyr && eyr && hgt && hcl && ecl && pid
  end

  def valid?
    return false unless number_in_range?(byr, 1920..2002)
    return false unless number_in_range?(iyr, 2010..2020)
    return false unless number_in_range?(eyr, 2020..2030)

    return false unless hgt
    hgt =~ /^(\d+)(\w+)$/
    height = $1

    case $2
    when "cm"
      return false unless number_in_range?(height, 150..193)
    when "in"
      return false unless number_in_range?(height, 59..76)
    else
      return false
    end

    return false unless hcl.try &.match(/^#[0-9a-f]{6}$/)
    return false unless ecl.try &.match(/^(amb|blu|brn|gry|grn|hzl|oth)$/)
    return false unless pid.try &.match(/^[0-9]{9}$/)

    true
  end

  private def number_in_range?(value, range)
    value && value.try(&.to_i?) && range.includes?(value.to_i)
  end
end

lines = File.read_lines("input.txt")

# Separate by blank lines, and join the blocks with spaces
passports = lines
  .chunks(&.blank?)
  .reject! { |blank, _| blank }
  .map { |_, lines| lines.join " " }
  .map &->Passport.build_from_string(String)

puts passports.count &.has_all_fields?
puts passports.count &.valid?
