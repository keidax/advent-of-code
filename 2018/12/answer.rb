#!/usr/bin/env ruby

RULES = {}
OFFSET = 21

initial_state = gets.chomp.sub('initial state: ', '')
gets # blank line

plants = '.' * (initial_state.size + OFFSET * 2)

while (line = gets&.chomp)
  match = line.match(/([#.]+) => ([#.])/)
  RULES[match[1]] = match[2]
end
