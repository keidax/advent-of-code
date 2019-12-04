#!/usr/bin/env ruby

require 'time'
require 'pp'

class Entry
  include Comparable

  attr_accessor :time, :id

  def initialize(string)
    match = string.match(/\[(.*)\] (.*)/)
    self.time = Time.strptime(match[1], '%F %R')

    self.id = case match[2]
    when /falls asleep/
      :asleep
    when /wakes up/
      :awake
    when /Guard #(\d+) begins shift/
      $1.to_i
    end
  end

  def <=>(other)
    self.time <=> other.time
  end
end

class Shift
  attr_accessor :entries

  def initialize
    self.entries = []
  end

  def <<(entry)
    entries << entry

    self
  end

  def id
    entries.first&.id
  end

  def ranges
    @ranges ||= begin
      ranges = []
      start = nil

      entries.each do |entry|
        case entry.id
        when :asleep
          start = entry.time
        when :awake
          ranges << (start...entry.time)
          start = nil
        end
      end

      ranges
    end
  end

  def time_asleep
    @time_asleep ||= ranges.map { |r| r.last - r.first }.sum
  end
end

class Guard
  include Comparable

  attr_accessor :shifts

  def initialize
    self.shifts = []
  end

  def <<(shift)
    shifts << shift
  end

  def id
    shifts.first&.id
  end

  def time_asleep
    shifts.map(&:time_asleep).sum
  end

  def <=>(other)
    self.time_asleep <=> other.time_asleep
  end

  def most_common_minute
    minutes = Array.new(60, 0)

    for shift in shifts
      for range in shift.ranges
        time = range.begin
        while range.cover? time
          minutes[time.min] += 1
          time += 60
        end
      end
    end

    minutes.index(minutes.max)
  end
end

entries = []

while (line = gets&.chomp)
  entries << Entry.new(line)
end
entries.sort!

shifts = []
shift = nil
for entry in entries
  if entry.id.is_a? Integer
    shifts << shift if shift
    shift = Shift.new
  end

  shift << entry
end
shifts << shift

guards = Hash.new { |h, k| h[k] = Guard.new }

for shift in shifts
  id = shift.id
  guard = guards[id]
  guard << shift
end

guard = guards.values.max

puts guard.id * guard.most_common_minute
