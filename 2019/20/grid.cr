class Tile
  property x, y
  property distance
  property? visited
  property! portal : Tile?
  property! grid : Grid?

  EMPTY = new(-1, -1, nil)

  def initialize(@x : Int32, @y : Int32, @grid)
    @distance = Int32::MAX
    @visited = false
  end

  def empty?
    self == EMPTY
  end

  def neighbors
    grid.neighbors(self)
  end
end

class Grid
  @data : Array(Array(Tile))
  property! start_portal : Tile, end_portal : Tile
  property portals : Hash(String, {outer: Tile, inner: Tile})

  def initialize(input : String)
    # For looking up chars in other rows or columns
    char_data = input.lines.map &.chars

    @portals = Hash(String, {outer: Tile, inner: Tile}).new

    @data = Array(Array(Tile)).new
    portal_pairs = Hash(String, Array(Tile)).new

    input.each_line.with_index do |line, y|
      row = Array(Tile).new
      @data << row

      line.each_char_with_index do |char, x|
        case char
        when '.'
          row << Tile.new(x, y, self)
        when ' ', '#'
          row << Tile::EMPTY
        when .ascii_uppercase?
          above, below = char_data.dig?(y - 1, x), char_data.dig?(y + 1, x)
          left, right = char_data.dig?(y, x - 1), char_data.dig?(y, x + 1)
          other_char = if above == '.'
                         below
                       elsif below == '.'
                         above
                       elsif left == '.'
                         right
                       elsif right == '.'
                         left
                       else
                         # We don't care about this char.
                         nil
                       end

          unless other_char
            # The other char must be the portal location, so skip this one
            row << Tile::EMPTY
            next
          end

          portal_tile = Tile.new(x, y, self)
          row << portal_tile
          # We can ignore the order of labels by always alphabetizing
          # (This assumes each pair is distinct.)
          full_label = [char, other_char].sort.join ""

          list = portal_pairs[full_label] ||= Array(Tile).new
          list << portal_tile
        else
          # raise "unexpected map character #{char}"
        end
      end
    end

    # Above we represented portal labels as their own tiles
    # Now remove the portal tiles and link open tiles themselves.
    portal_pairs.each do |label, pairs|
      if label == "AA"
        orig_tile = pairs[0]
        @start_portal = neighbors(orig_tile).first
        clear(orig_tile)

        next
      end

      if label == "ZZ"
        orig_tile = pairs[0]
        @end_portal = neighbors(orig_tile).first
        clear(orig_tile)

        next
      end

      tile1, tile2 = Tuple(Tile, Tile).from pairs
      link1, link2 = neighbors(tile1).first, neighbors(tile2).first

      link1.portal = link2
      link2.portal = link1

      # Determine which portal is on the outer edge of the torus, and which is on the inner.
      outer, inner = [link1, link2].partition do |tile|
        tile.y == 2 ||
          tile.x == 2 ||
          tile.y == @data.size - 3 ||
          tile.x == @data[0].size - 3
      end.map &.first

      @portals[label] = {outer: outer, inner: inner}

      clear(tile1)
      clear(tile2)
    end
  end

  def [](i : Int32)
    @data[i]
  end

  def clear(tile)
    @data[tile.y][tile.x] = Tile::EMPTY
  end

  def neighbors(x, y) : Array(Tile)
    tile = @data[y][x]

    neighbors(tile)
  end

  def neighbors(tile)
    offsets = [
      {0, 1},
      {0, -1},
      {1, 0},
      {-1, 0},
    ]

    neighbors = offsets.compact_map do |x_off, y_off|
      @data.dig?(tile.y + y_off, tile.x + x_off)
    end

    if tile.portal?
      neighbors << tile.portal
    end

    neighbors.reject! &.empty?
  end
end
