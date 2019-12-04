#!/usr/bin/env ruby

require 'set'

def quickdiff(a, b)
  d = 0
  a.each_char.with_index do |c, i|
    if b[i] != c
      d +=1
      if d > 1
        return d
      end
    end
  end

  return d
end

def common(a, b)
  s = ''
  a.each_char.with_index do |c, i|
    if b[i] == c
      s << c
    end
  end
  s
end

lines = [gets&.chomp]

while (line = gets&.chomp)
  for prev in lines
    if quickdiff(line, prev) == 1
      puts common line, prev
      exit
    end
  end

  lines << line
end
