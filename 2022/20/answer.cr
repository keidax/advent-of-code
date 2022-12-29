require "../aoc"

AOC.day!(20)

numbers = Array(Int64).new

AOC.lines.each_with_index do |line, i|
  numbers << line.to_i
end

def mix_numbers(numbers : Enumerable(Int64), rounds = 1) : Array(Int64)
  numbers_with_index = numbers.zip(0...numbers.size)

  sequence = numbers_with_index.clone

  rounds.times do
    mix_with_index(numbers_with_index, sequence)
  end

  sequence.map(&.[0])
end

def mix_with_index(numbers_i, sequence)
  size = numbers_i.size
  numbers_i.each do |number_i|
    index = sequence.index!(number_i)
    sequence.delete(number_i)

    index = (number_i[0] + index) % (size - 1)

    if index == 0
      sequence.push(number_i)
    else
      sequence.insert(index, number_i)
    end
  end
end

def find_coordinates(mixed)
  zero_index = mixed.index!(0)

  a = mixed[(zero_index + 1000) % mixed.size]
  b = mixed[(zero_index + 2000) % mixed.size]
  c = mixed[(zero_index + 3000) % mixed.size]

  a + b + c
end

AOC.part1 do
  mixed = mix_numbers(numbers)
  find_coordinates(mixed)
end

KEY = 811589153

AOC.part2 do
  mixed = mix_numbers(numbers.map { |n| n * KEY }, rounds: 10)
  find_coordinates(mixed)
end
