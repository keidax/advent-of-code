floor = 0
File.each_line("input.txt") do |line|
    line.each_char do |char|
        case char
        when '('
            floor += 1
        when ')'
            floor -= 1
        end
    end
end
puts floor
