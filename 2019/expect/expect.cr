require "colorize"

def xexpect(name, input, expected)
  puts "#{name}: skipped".colorize(:dark_gray)
end

# Call the macro with _input_ as a tuple, which looks neater.
# But expand _input_ when calling answer, to take advantage of automatic casting.
macro expect(name, input, expected)
  actual = answer({{ input.splat }})
  if actual == {{ expected }}
    with_color(:green).surround do |io|
      io.puts "#{ {{ name }} }: #{actual} ✔️"
    end
  else
    with_color(:red).surround do |io|
      io.puts "#{ {{ name }} }: #{actual} != #{ {{ expected }} }"
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
