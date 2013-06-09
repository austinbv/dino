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
		sketch_file = DinoCLI::Generator.run!(options)

		options[:upload] ? DinoCLI::Uploader.run!(file: sketch_file) : $stdout.puts(sketch_file)
	end
end
