#!/usr/bin/env ruby

require 'set'

steps = {}

while (line = gets&.chomp)
  match = line.match /Step (.*) must be finished before step (.*) can begin./

  prereq, next_step = match[1, 2]
  steps[prereq] ||= Set.new
  steps[next_step] ||= Set.new
  steps[next_step] << prereq
end

pp steps

completed = Set.new
output = ''
possible = SortedSet.new

while output.size < steps.size
  possible.clear

  for next_step, prereqs in steps
    next if completed.include? next_step

    if prereqs <= completed
      possible << next_step
    end
  end

  step = possible.first
  puts "finishing step #{step}"
  output << step
  completed << step
end

puts output
