require "./grid"

class Tile
  # Represent unconnected portals
  OUTER = new(-1, -1, nil)
  INNER = new(-1, -1, nil)
end

class RecursiveGrid < Grid
  property! outer_grid : RecursiveGrid?, inner_grid : RecursiveGrid?

  # We need to keep a reference to the input string, for creating more nested grids
  @input : String

  def initialize(@input)
    super(input)

    @portals.each do |_, pair|
      pair[:outer].portal = Tile::OUTER
      pair[:inner].portal = Tile::INNER
    end
  end

  def initialize(input, @outer_grid)
    initialize(input)
  end

  def neighbors(tile)
    if tile.portal?
      if tile.portal == Tile::OUTER || tile.portal == Tile::INNER
        link(tile)
      end
    end

    super
  end

  private def link(tile)
    label = @portals.each_key.find do |key|
      pair = @portals[key]
      pair[:inner] == tile || pair[:outer] == tile
    end.not_nil!

    if tile.portal == Tile::OUTER
      unless outer_grid?
        # Only the top level won't have an outer grid. We can't link in this case.
        tile.portal = nil
        return
      end

      other_end = outer_grid.portals[label][:inner]
      other_end.portal = tile
      tile.portal = other_end
    else
      unless inner_grid?
        # This is the first time reaching the next level, create the inner grid
        @inner_grid = RecursiveGrid.new(@input, self)
      end

      other_end = inner_grid.portals[label][:outer]
      other_end.portal = tile
      tile.portal = other_end
    end
  end
end
