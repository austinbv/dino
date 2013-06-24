class DinoCLI::Uploader
  require "pathname"
  require "fileutils"
  attr_reader :options

  def initialize(options={})
    @options = options
  end

  def self.run!(options={})
    instance = self.new(options)

    if options[:upload]
      instance.upload
    elsif options[:compile]
      instance.compile
    end
  end

  def compile
    output = `#{executable} --verify --verbose '#{options[:sketch_file]}'`

    tmp_hex_file = output.match(/elf.*.hex/)[0].gsub("elf", "").lstrip
    FileUtils::copy(tmp_hex_file, options[:output_dir])

    hex_file = File.join(options[:output_dir], Pathname.new(tmp_hex_file).basename)
    $stdout.puts hex_file
  end

  def upload
    `#{executable} --upload '#{options[:sketch_file]}'`
  end

  def executable
    return "/Applications/Arduino.app/Contents/MacOS/JavaApplicationStub" if RUBY_PLATFORM.match(/darwin/i)
  end
end
