require_relative "aoc"

input = AOC.day(9)
disk_map = input.lines(chomp: true)[0]

def disk_map_to_array(disk_map)
  disk = []
  file_id = 0

  disk_map.chars.each_slice(2) do |file_size, free_size|
    disk.fill(file_id, disk.size, file_size.to_i)
    file_id += 1

    break unless free_size
    disk.fill(nil, disk.size, free_size.to_i)
  end

  disk
end

def compact(disk)
  first_space_idx = disk.index(nil)

  loop do
    disk[first_space_idx] = disk.last
    disk.pop

    while disk.last.nil?
      disk.pop
    end

    while first_space_idx < disk.size && !disk[first_space_idx].nil?
      first_space_idx += 1
    end

    break if first_space_idx >= disk.size
  end
  disk
end

def checksum(disk)
  disk.each_with_index.sum do |file_id, i|
    file_id * i
  end
end

class DiskFile
  attr_reader :size
  attr_reader :file_id
  attr_accessor :index

  def initialize(file_id:, size:, index:)
    raise "size must be greater than 0" unless size > 0
    @size = size
    @index = index
    @file_id = file_id
  end

  # calculate the checksum for every block in the file at once
  def checksum
    positions = index...(index + size)
    @file_id * positions.sum
  end
end

class DiskSpace
  attr_accessor :size
  attr_accessor :index

  def initialize(size:, index:)
    raise "size must be greater than 0" unless size > 0
    @size = size
    @index = index
  end
end

def disk_map_to_objects(disk_map)
  free_spaces = []
  files = []

  file_id = 0
  index = 0

  disk_map.chars.each_slice(2) do |file_size, free_size|
    size = file_size.to_i

    files << DiskFile.new(file_id:, index:, size:)

    file_id += 1
    index += size

    break unless free_size

    size = free_size.to_i
    next if size < 1

    free_spaces << DiskSpace.new(index:, size:)
    index += size
  end

  [files, free_spaces]
end

def defrag(disk_map)
  files, free_spaces = disk_map_to_objects(disk_map)

  files.reverse_each do |file|
    try_to_move(file, free_spaces)
  end

  files
end

# Try to find a free space to the left of file, and move file into that space.
# If no eligible space is found, don't do anything.
# Assumes free_spaces is already sorted on space.index
def try_to_move(file, free_spaces)
  free_space_idx = free_spaces.find_index do |space|
    # Make sure we're only searching to the left of the file
    break if space.index > file.index

    space.size >= file.size
  end

  return unless free_space_idx

  space = free_spaces[free_space_idx]

  file.index = space.index

  # Because our defrag algorithm runs only once, and checks files right-to-left,
  # we don't need to worry about maintaining the space that the file has just
  # vacated.

  space.size -= file.size
  space.index += file.size

  if space.size <= 0
    free_spaces.delete_at(free_space_idx)
  end
end

AOC.part1 do
  disk_map_to_array(disk_map)
    .then { compact(_1) }
    .then { checksum(_1) }
end

AOC.part2 do
  defrag(disk_map).sum(&:checksum)
end
