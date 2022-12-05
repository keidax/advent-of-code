require "http/request"
require "http/client"

module AOC
  INPUT_PATH = "input.txt"

  @@day : Int32 = 0

  def self.day!(day : Int32)
    @@day = day
  end

  @@input_loaded = false
  @@input : String = ""

  def self.each_line
    load_input!

    @@input.each_line do |line|
      yield line
    end
  end

  def self.lines
    load_input!

    @@input.lines
  end

  def self.input
    load_input!

    @@input
  end

  def self.part1
    log("Part 1: #{yield}")
  end

  def self.part2
    log("Part 2: #{yield}")
  end

  private def self.load_input!
    unless @@input_loaded
      @@input = load_input(@@day)
    end
  end

  private def self.load_input(day)
    input_path =
      if File.exists?(INPUT_PATH)
        File.read(INPUT_PATH)
      else
        download_file(day)
      end
  end

  private def self.download_file(day)
    log ">> downloading input for the first time"

    client = HTTP::Client.new("adventofcode.com", tls: true)
    get_input = HTTP::Request.new(method: "GET", resource: "/2022/day/#{day}/input")
    get_input.cookies["session"] = ENV["AOC_SESSION"]

    response = client.exec get_input
    input = response.body

    File.write(INPUT_PATH, input)
    input
  end

  private def self.log(message)
    puts "🎄 AOC Day #{@@day} #{message}"
  end
end
