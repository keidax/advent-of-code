require "colorize"

def expect(name, input, expected)
  actual = answer(input)
  if actual == expected
    with_color(:green).surround do |io|
      io.puts "#{name}: #{actual} ✔️"
    end
  else
    with_color(:red).surround do |io|
      io.puts "#{name}: #{actual} != #{expected}"
    end

    # Make sure exit status indicates failure
    at_exit do |status|
      exit(1) if status.zero?
    end
  end
end

def when_verbose(&)
  if ARGV.includes?("--verbose") || ENV["VERBOSE"]?.presence
    yield
  end
end
