module DinoCLI
  require "dino_cli/parser"
  require "dino_cli/generator"
  require "dino_cli/uploader"

  COMMANDS = ["generate-sketch"]
  SKETCHES = ["serial", "ethernet", "wifi"]
  
  def self.start(options={})
    parsed_options = DinoCLI::Parser.run(options)

    method = parsed_options[:command].gsub('-', '_').to_s
    self.send method, options
  end

  def self.generate_sketch(options)
    options = DinoCLI::Generator.run!(options)
    
    if options[:upload] || options[:compile]
      DinoCLI::Uploader.run!(options)
    else
      $stdout.puts options[:sketch_file]
    end
  end
end
