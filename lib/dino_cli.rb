module DinoCLI
  require "dino_cli/parser"
  require "dino_cli/generator"

  TASKS    = ["sketch"]
  SKETCHES = ["serial", "ethernet", "wifi"]

  def self.start(options={})
    options = DinoCLI::Parser.run(options)
    method = options[:task]
    self.send method, options
  end

  def self.sketch(options)
    result = DinoCLI::Generator.run!(options)
    $stdout.puts result[:sketch_folder]
  end
end
