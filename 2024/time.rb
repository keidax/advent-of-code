require "benchmark"
require_relative "aoc"

files = (1..25)
  .map { "%02d.rb" % _1 }
  .filter { File.exist?(_1) }

Benchmark.bm(0, "total") do |x|
  times = files.map do |filename|
    puts filename
    x.report(filename) { load(filename) }
  end

  [times.reduce(:+)]
end
