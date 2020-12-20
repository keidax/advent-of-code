class Expression
  property nodes : Array(Expression | Char | Int64)

  def initialize(line : String)
    tokens = line.chars.reject(&.whitespace?).map do |c|
      if c.number?
        c.to_i64
      else
        c
      end
    end

    initialize(tokens)
  end

  def initialize(tokens)
    @nodes = [] of Expression | Char | Int64

    while tokens.any?
      case tokens.first
      when '('
        tokens.shift
        nodes << Expression.new(tokens)
      when ')'
        tokens.shift
        break
      when Char, Int64
        nodes << tokens.shift
      end
    end
  end

  def value : Int64
    nodes = @nodes.dup

    val = value(nodes.shift).to_i64

    while nodes.any?
      case nodes.shift
      when '+'
        val += value(nodes.shift)
      when '*'
        val *= value(nodes.shift)
      end
    end

    val
  end

  def value_pt2 : Int64
    nodes = @nodes.dup

    while (plus_idx = nodes.index('+'))
      lhi = plus_idx - 1
      rhi = plus_idx + 1

      nodes[lhi..rhi] = value_pt2(nodes[lhi]) + value_pt2(nodes[rhi])
    end

    while (mult_idx = nodes.index('*'))
      lhi = mult_idx - 1
      rhi = mult_idx + 1

      nodes[lhi..rhi] = value_pt2(nodes[lhi]) * value_pt2(nodes[rhi])
    end

    unless nodes.size == 1
      raise "unexpected nodes: #{nodes}"
    end

    nodes[0].as(Int64)
  end

  private def value(node) : Int64
    if node.is_a?(Expression)
      node.value
    elsif node.is_a?(Int64)
      node
    else
      raise "node #{node} has no value"
    end
  end

  private def value_pt2(node) : Int64
    if node.is_a?(Expression)
      node.value_pt2
    elsif node.is_a?(Int64)
      node
    else
      raise "node #{node} has no value"
    end
  end
end

expressions = File.read_lines("input.txt").map { |line| Expression.new(line) }

# Part 1
puts expressions.sum &.value
# Part 2
puts expressions.sum &.value_pt2
