#!/usr/bin/env ruby

# Circular linked list
class Node
  attr_accessor :value, :next, :prev

  def initialize(value, prev: nil)
    self.value = value

    if prev
      self.next = prev.next
      self.prev = prev

      prev.next = self
      self.next.prev = self
    end
  end

  # Return the node that is `index` nodes ahead or behind of this node
  def get_node(index)
    if index.zero?
      self
    elsif index.positive?
      self.next.get_node(index - 1)
    else
      prev.get_node(index + 1)
    end
  end

  def insert(value, offset:)
    offset_node = get_node(offset)
    self.class.new(value, prev: offset_node)
  end

  def delete(offset)
    if offset.zero?
      prev.next = self.next
      self.next.prev = prev

      self.next = nil
      self.prev = nil

      self
    else
      get_node(offset).delete(0)
    end
  end

  class << self
    def begin_new(value)
      node = new(value)
      node.next = node
      node.prev = node

      node
    end
  end
end

def highest_score(player_count, marble_count)
  current_marble = Node.begin_new(0)
  players = Hash.new { |h, k| h[k] = 0 }

  (1..marble_count).zip((1..player_count).cycle).each do |marble, player|
    unless marble % 23 == 0
      current_marble = current_marble.insert(marble, offset: 1)
      next
    end

    current_marble = current_marble.get_node(-6)
    removed_marble = current_marble.delete(-1)
    players[player] += marble + removed_marble.value
  end

  players.values.max
end

while (line = gets&.chomp)
  match = line.match(/(\d+) players; last marble is worth (\d+) points/)
  players, marble_count = match[1, 2].map(&:to_i)
  puts highest_score(players, marble_count)
end
