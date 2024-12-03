require "net/http"
require "cgi/cookie"
require "forwardable"

module AOC
  YEAR = 2024

  def self.day(n)
    Input.new(n)
  end

  def self.log(message)
    puts "❄️  #{message}"
  end

  def self.part1
    log("part 1 : #{yield}")
  end

  def self.part2
    log("part 2 : #{yield}")
  end

  class Input
    def initialize(day)
      @day = day
    end

    def input_path
      "%02d_input.txt" % @day
    end

    def input
      @input ||= load_input
    end

    extend Forwardable
    def_delegators :input, :each_line, :lines, :scan

    private

    def load_input
      if File.exist?(input_path)
        File.read(input_path)
      else
        download_file
      end
    end

    def download_file
      AOC.log ">> downloading input for the first time"

      uri = URI("https://adventofcode.com/#{AOC::YEAR}/day/#{@day}/input")
      cookie = CGI::Cookie.new("session", ENV["AOC_SESSION"])
      headers = {"Cookie" => cookie.to_s}
      resp = Net::HTTP.get_response(uri, headers)

      unless Net::HTTPOK === resp
        raise "Error fetching puzzle input:\n#{resp.body}"
      end

      File.write(input_path, resp.body)
      resp.body
    end
  end
end
