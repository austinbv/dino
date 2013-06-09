class DinoCLI::Uploader
  attr_reader :options

  def initialize(options={})
    @options = options
  end

  def self.run!(options={})
    instance = self.new(options)

    instance.upload
  end

  def upload
    if RUBY_PLATFORM.match /darwin/i
      system("/Applications/Arduino.app/Contents/MacOS/JavaApplicationStub --upload '#{options[:file]}'")
    end
  end
end
