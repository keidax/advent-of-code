require "http/request"
require "http/client"

module AOC
  YEAR = 2023

  @@day : Int32 = 0

  def self.day!(day : Int32)
    @@day = day
  end

  def self.input_path
    "%02d_input.txt" % @@day
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

  def self.line_sections : Array(Array(String))
    lines.slice_after("").map do |section|
      # clean out the blank lines
      section.reject("")
    end.to_a
  end

  def self.input
    load_input!

    @@input
  end

  def self.part1
    log("part 1 : #{yield}")
  end

  def self.part2
    log("part 2 : #{yield}")
  end

  private def self.load_input!
    unless @@input_loaded
      @@input = load_input(@@day)
    end
  end

  private def self.load_input(day)
    if File.exists?(input_path)
      File.read(input_path)
    else
      download_file(day)
    end
  end

  private def self.download_file(day)
    log ">> downloading input for the first time"

    client = HTTP::Client.new("adventofcode.com", tls: true)
    get_input = HTTP::Request.new(method: "GET", resource: "/#{YEAR}/day/#{day}/input")
    get_input.cookies["session"] = ENV["AOC_SESSION"]

    response = client.exec get_input
    input = response.body

    unless response.status.ok?
      raise "Error fetching puzzle input: #{input}"
    end

    File.write(input_path, input)
    input
  end

  private def self.log(message)
    puts "❄️  #{message}"
  end
end
