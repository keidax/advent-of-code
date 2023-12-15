require "./aoc"

AOC.day!(15)

def hash_algo(str : String)
  str.chars.reduce(0) do |acc, c|
    acc += c.ord
    acc *= 17
    acc %= 256
  end
end

def do_step(boxes, step)
  step.match!(/\w+/)
  label = $~[0]

  box_num = hash_algo(label)
  box = if boxes.has_key?(box_num)
          boxes[box_num]
        else
          boxes[box_num] = [] of {String, Int32}
        end

  case step
  when /\w+-/
    box.reject! { |(lens_label, _)| lens_label == label }
  when /\w+=(\d+)/
    focal_length = $~[1].to_i

    i = box.index { |(lens_label, _)| lens_label == label }

    if i
      box[i] = {label, focal_length}
    else
      box << {label, focal_length}
    end
  end
end

def focusing_power(boxes)
  boxes.sum do |(box_num, box)|
    box.each_with_index.sum do |(_label, focal_length), i|
      (box_num + 1) * (i + 1) * focal_length
    end
  end
end

steps = AOC.lines.first.split(",")

AOC.part1 do
  steps.sum { |s| hash_algo(s) }
end

AOC.part2 do
  boxes = {} of Int32 => Array({String, Int32})
  steps.each { |step| do_step(boxes, step) }
  focusing_power(boxes)
end
