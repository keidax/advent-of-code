require "./multi_grid"
require "./graph"

class MultiGraph
  getter graphs : Array(Graph)

  def initialize(grid : MultiGrid)
    @graphs = grid.starts.map do |start|
      Graph.new(grid, start).tap { |graph| graph.simplify! }
    end
  end

  @all_keys : Set(Char)?

  def all_keys : Set(Char)
    @all_keys ||= @graphs.map(&.all_keys).reduce do |keys1, keys2|
      keys1 + keys2
    end
  end
end
