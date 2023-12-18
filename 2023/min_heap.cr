class MinHeap(K)
  @tree = [] of K
  @values = {} of K => Int32

  def value?(item : K) : Int32?
    @values[item]?
  end

  def insert(item : K, value : Int32)
    if @values.has_key?(item)
      raise "item is already present in heap"
    end

    @values[item] = value

    free_space = @tree.size
    @tree << item
    float(free_space, value)
    self
  end

  private def float(index, value)
    return if index == 0 # no need to float the root

    parent_index = (index - 1) // 2
    parent_item = @tree[parent_index]
    parent_value = @values[parent_item]

    if parent_value < value
      # all good
    else
      @tree[parent_index], @tree[index] = @tree[index], @tree[parent_index]
      float(parent_index, value)
    end
  end

  def shift : {K, Int32}
    if @tree.size == 0
      raise "empty"
    end

    item = @tree[0]
    value = @values.delete(item).not_nil!

    if @tree.size > 1
      new_root = @tree.delete_at(@tree.size - 1)
      @tree[0] = new_root
      new_root_val = @values[new_root]

      sink(0, new_root_val)
    else
      @tree.delete_at(0)
    end

    {item, value}
  end

  private def sink(index, value)
    left_i = 2*index + 1
    right_i = 2*index + 2

    if left_i >= @tree.size
      # children don't exist
    elsif right_i >= @tree.size
      # only left child exists
      left_val = @values[@tree[left_i]]

      if value <= left_val
        # all good
      else
        @tree[left_i], @tree[index] = @tree[index], @tree[left_i]
        sink(left_i, value)
      end
    else
      # both children exist
      left_val = @values[@tree[left_i]]
      right_val = @values[@tree[right_i]]

      if value <= right_val && value <= left_val
        # all good
      elsif right_val < left_val
        @tree[right_i], @tree[index] = @tree[index], @tree[right_i]
        sink(right_i, value)
      else
        # left val less
        @tree[left_i], @tree[index] = @tree[index], @tree[left_i]
        sink(left_i, value)
      end
    end
  end

  def update(item : K, value : Int32)
    old_value = @values[item]?

    unless old_value
      raise "item is not present in heap"
    end

    if value == old_value
      return
    end

    @values[item] = value

    index = @tree.rindex!(item)

    if value < old_value
      float(index, value)
    else
      sink(index, value)
    end
  end
end
