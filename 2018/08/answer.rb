#!/usr/bin/env ruby

class Node
  attr_accessor :children, :metadata

  def initialize
    self.children = []
    self.metadata = []
  end

  def metadata_sum
    metadata.sum + children.map(&:metadata_sum).sum
  end

  class << self
    def from_input
      node = new

      num_children, num_metadata = read_header

      num_children.times do
        node.children << from_input
      end

      node.metadata.concat(read_metadata(num_metadata))

      node
    end

    private

    def read_header
      [gets(' ').strip.to_i, gets(' ').strip.to_i]
    end

    def read_metadata(num)
      metadata = []

      num.times do
        metadata << gets(' ').strip.to_i
      end

      metadata
    end
  end
end

root = Node.from_input
puts root.metadata_sum
