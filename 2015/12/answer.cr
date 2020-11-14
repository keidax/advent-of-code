require "json"

json = File.open("input.json") { |file| JSON.parse(file) }

# Part 1
def sum_numbers(json : JSON::Any) : Int64
  case json.raw
  when Array
    json.as_a.sum &->sum_numbers(JSON::Any)
  when Hash
    json.as_h.values.sum &->sum_numbers(JSON::Any)
  when Int64
    json.as_i64
  else
    0_i64
  end
end

puts sum_numbers(json)

# Part 2
def sum_non_red_numbers(json : JSON::Any) : Int64
  case json.raw
  when Array
    json.as_a.sum &->sum_non_red_numbers(JSON::Any)
  when Hash
    hash = json.as_h
    if hash.values.any? do |val|
         val.as_s? == "red"
       end
      return 0_i64
    end
    json.as_h.values.sum &->sum_non_red_numbers(JSON::Any)
  when Int64
    json.as_i64
  else
    0_i64
  end
end

puts sum_non_red_numbers(json)
