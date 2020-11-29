def iteration_times(row : Int64, column : Int64) : Int64
  diagonal = (column + row - 1)
  sum = diagonal * (diagonal + 1) // 2
  sum - row
end

def iterate(num) : Int64
  num * 252533 % 33554393
end

# Part 1
num = 20151125_i64
time = iteration_times(2947, 3029)
time.times { num = iterate(num) }
pp num
