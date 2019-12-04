#!/usr/bin/env ruby

require 'set'

class Step
  attr_accessor :active, :done, :letter, :remaining

  def initialize(letter)
    self.letter = letter
    self.active = false
    self.done = false
  end

  def unstarted?
    !active && !done
  end

  def cost
    @cost ||= (letter.ord - 'A'.ord) + 61 # TODO: needs to be + 61
  end

  def start_work
    self.active = true
    self.remaining = cost

    self
  end

  def tick
    if active
      self.remaining -= 1

      if self.remaining <= 0
        self.active = false
        self.done = true
      end
    end
  end

  def hash
    letter.hash
  end

  def eql?(other)
    letter.eql? other.letter
  end

  def <=>(other)
    letter <=> other.letter
  end
end

class Worker
  attr_accessor :step

  def free?
    !step
  end

  def tick
    step.tick

    if step.done
      self.step = nil
    end

    self
  end
end

steps = {}

while (line = gets&.chomp)
  match = line.match /Step (.*) must be finished before step (.*) can begin./

  prereq = Step.new(match[1])
  next_step = Step.new(match[2])

  prereq = steps.keys.find {|s| s.eql? prereq } if steps.key? prereq
  next_step = steps.keys.find {|s| s.eql? next_step } if steps.key? next_step

  steps[prereq] ||= Set.new
  steps[next_step] ||= Set.new
  steps[next_step] << prereq
end

pp steps

possible = SortedSet.new
ticks = 0

workers = Array.new(5) { Worker.new }

until steps.keys.all?(&:done)
  possible.clear

  for next_step, prereqs in steps

    next unless next_step.unstarted?

    if prereqs.all?(&:done)
      possible << next_step
    end
  end

  free_workers = workers.select(&:free?)

  free_workers.each do |worker|
    break if possible.empty?

    next_step = possible.first
    next_step.start_work
    worker.step = next_step
    possible.delete(next_step)
  end

  hard_workers = workers.reject(&:free?)
  hard_workers.each &:tick

  ticks += 1
end

puts ticks
