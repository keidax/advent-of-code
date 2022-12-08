require "../aoc"

AOC.day!(7)

class Directory
  property contents : Hash(String, Directory | FileObj)

  def initialize
    @contents = {} of String => Directory | FileObj
  end

  @size : Int64?

  def size
    @size ||= contents.values.sum(&.size)
  end
end

class FileObj
  property size : Int64

  def initialize(@size)
  end
end

directories = [] of Directory
root = Directory.new
dir_stack = [] of Directory

AOC.each_line do |line|
  case line
  when /\$ cd \//
    dir_stack = [root]
  when /\$ cd (\w+)/
    name = $1
    new_dir = dir_stack.last.contents[name]
    dir_stack << new_dir.as(Directory)
  when /\$ cd ../
    dir_stack.pop
  when /\$ ls/
    # don't need to do anything
  when /(\d+) (.+)/
    size = $1.to_i64
    name = $2
    dir_stack.last.contents[name] = FileObj.new(size)
  when /dir (\w+)/
    name = $1
    dir = Directory.new
    dir_stack.last.contents[name] = dir
    directories << dir
  else
    raise "can't process line '#{line}'"
  end
end

TOTAL_SIZE    = 70000000
MIN_FREE_SIZE = 30000000

AOC.part1 { directories.map(&.size).select { |s| s <= 100000 }.sum }

AOC.part2 do
  unused_size = TOTAL_SIZE - root.size
  need_to_free = MIN_FREE_SIZE - unused_size

  eligible_sizes = directories.map(&.size).select { |s| s >= need_to_free }
  eligible_sizes.sort.first
end
