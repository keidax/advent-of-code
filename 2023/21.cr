require "./aoc"

AOC.day!(21)

tiles = AOC.lines.map(&.chars)

start = {row: -1, col: -1}
(0...tiles.size).each do |row|
  (0...tiles[row].size).each do |col|
    if tiles[row][col] == 'S'
      start = {row: row, col: col}
      tiles[row][col] = '.'
    end
  end
end

reachable = [] of Set({row: Int32, col: Int32})
reachable << Set.new [start]

alias AdjTile = {row: Int32, col: Int32, tile: Char}

def grid_adjacent(grid : Indexable(Indexable(Char)), x, y) : Tuple(AdjTile, AdjTile, AdjTile, AdjTile)
  {
    {-1, 0},
    {1, 0},
    {0, 1},
    {0, -1},
  }.map do |dx, dy|
    ax = x + dx
    ay = y + dy

    ay_clamped = ay % grid.size
    ax_clamped = ax % grid[ay_clamped].size

    {col: ax, row: ay, tile: grid[ay_clamped][ax_clamped]}
  end
end

def take_step(tiles, reachable)
  current = reachable.last
  next_step = Set({row: Int32, col: Int32}).new(initial_capacity: current.size*2)

  current.each do |cur|
    grid_adjacent(tiles, x: cur[:col], y: cur[:row]).each do |adj|
      if adj[:tile] == '.'
        next_step << {row: adj[:row], col: adj[:col]}
      end
    end
  end

  reachable << next_step
end

AOC.part1 do
  while reachable.size <= 64
    take_step(tiles, reachable)
  end

  reachable[64].size
end

def region_bounds(tiles, rows, cols)
  tile_height = tiles.size
  tile_width = tiles[0].size

  row_top = tile_height * rows
  row_bottom = tile_height * (rows + 1) - 1

  col_left = tile_width * cols
  col_right = tile_width * (cols + 1) - 1

  {rows: (row_top..row_bottom), cols: (col_left..col_right)}
end

def reachable_in_bounds(reachable, bounds)
  reachable.map do |step|
    step.select do |tile|
      bounds[:cols].includes?(tile[:col]) && bounds[:rows].includes?(tile[:row])
    end
  end
end

def area_metrics(reachable, tile_size)
  sizes = reachable.map(&.size)

  lag = sizes.index! { |r| r > 0 }

  max = sizes.max
  time_to_max = sizes.index!(max)
  time_to_fill = time_to_max - lag

  sizes = sizes[lag..(time_to_max + 1)]

  if lag > tile_size
    lag -= tile_size
  end

  {lag: lag, fill: time_to_fill, sizes: sizes}
end

def count_after_step(step, area_metrics, cycles, tile_size) : Int64
  begin_step = if cycles == 0
                 step - area_metrics[:lag]
               else
                 step - area_metrics[:lag] - tile_size * cycles
               end

  if begin_step < 0
    return 0i64
  elsif begin_step <= area_metrics[:fill]
    area_metrics[:sizes][begin_step].to_i64
  else
    begin_step -= area_metrics[:fill]
    begin_step %= 2
    area_metrics[:sizes][begin_step + area_metrics[:fill]].to_i64
  end
end

tile_height = tiles.size
tile_width = tiles[0].size

STEPS = 26501365

AOC.part2 do
  while reachable.size <= tiles.size*3
    take_step(tiles, reachable)
  end

  center_bound = region_bounds(tiles, rows: 0, cols: 0)
  center_north_bound = region_bounds(tiles, rows: -1, cols: 0)
  center_east_bound = region_bounds(tiles, rows: 0, cols: 1)
  center_south_bound = region_bounds(tiles, rows: 1, cols: 0)
  center_west_bound = region_bounds(tiles, rows: 0, cols: -1)

  north_bound = region_bounds(tiles, rows: -2, cols: 0)
  ne_bound = region_bounds(tiles, rows: -1, cols: 1)
  east_bound = region_bounds(tiles, rows: 0, cols: 2)
  se_bound = region_bounds(tiles, rows: 1, cols: 1)
  south_bound = region_bounds(tiles, rows: 2, cols: 0)
  sw_bound = region_bounds(tiles, rows: 1, cols: -1)
  west_bound = region_bounds(tiles, rows: 0, cols: -2)
  nw_bound = region_bounds(tiles, rows: -1, cols: -1)

  center = area_metrics(reachable_in_bounds(reachable, center_bound), tile_height)
  cn = area_metrics(reachable_in_bounds(reachable, center_north_bound), tile_height)
  ce = area_metrics(reachable_in_bounds(reachable, center_east_bound), tile_height)
  cs = area_metrics(reachable_in_bounds(reachable, center_south_bound), tile_height)
  cw = area_metrics(reachable_in_bounds(reachable, center_west_bound), tile_height)

  north = area_metrics(reachable_in_bounds(reachable, north_bound), tile_height)
  east = area_metrics(reachable_in_bounds(reachable, east_bound), tile_height)
  south = area_metrics(reachable_in_bounds(reachable, south_bound), tile_height)
  west = area_metrics(reachable_in_bounds(reachable, west_bound), tile_height)

  ne = area_metrics(reachable_in_bounds(reachable, ne_bound), tile_height)
  se = area_metrics(reachable_in_bounds(reachable, se_bound), tile_height)
  sw = area_metrics(reachable_in_bounds(reachable, sw_bound), tile_height)
  nw = area_metrics(reachable_in_bounds(reachable, nw_bound), tile_height)

  plots = count_after_step(STEPS, center, 0, tile_height)
  plots += count_after_step(STEPS, cn, 0, tile_height)
  plots += count_after_step(STEPS, ce, 0, tile_height)
  plots += count_after_step(STEPS, cw, 0, tile_height)
  plots += count_after_step(STEPS, cs, 0, tile_height)

  [north, south, east, west].each do |axis_region|
    (1..).each do |i|
      region_plots = count_after_step(STEPS, axis_region, i, tile_height)
      if region_plots > 0
        plots += region_plots
      else
        break
      end
    end
  end

  [ne, se, sw, nw].each do |diag_region|
    (1..).each do |i|
      region_plots = count_after_step(STEPS, diag_region, i, tile_height)
      if region_plots > 0
        plots += region_plots * i
      else
        break
      end
    end
  end

  plots
end
