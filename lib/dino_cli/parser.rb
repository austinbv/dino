class DinoCLI::Parser
  require 'dino_cli/helper'
  include DinoCLI::Helper

  def initialize(options={})
    @options = options
  end

  def self.run(options={})
    self.new(options).parse
  end

  def parse
    args = @options[:args].dup

    # Command must be the first arg.
    @options[:command] = args.shift
    usage if @options[:command].match /help|usage/
    error "Invalid command '#{@options[:command]}'"  unless DinoCLI::COMMANDS.include? @options[:command]

    # Parse the rest loosely.
    loop do
      case args[0]
        when 'serial'
          args.shift; set_sketch("serial")
        when 'ethernet'
          args.shift; set_sketch("ethernet")
        when 'wifi'
          args.shift; set_sketch("wifi")
        when '--baud'
          args.shift; @options[:baud] = args.shift
        when '--mac'
          args.shift; @options[:mac] = args.shift
        when '--ip'
          args.shift; @options[:ip] = args.shift
        when '--ssid'
          args.shift; @options[:ssid] = args.shift
        when '--password'
          args.shift; @options[:password] = args.shift
        when '--port'
          args.shift; @options[:port] = args.shift
        when '--debug'
          args.shift; @options[:debug] = true
        when '--compile'
          args.shift; @options[:compile] = true
        when '--upload'
          args.shift; @options[:upload] = true
        when /^-/
          error "Invalid argument '#{ARGV[0]}'"
        else break
      end
    end
    error "No valid sketch specified" if @options[:sketch_name].nil?

    @options
  end

  def set_sketch(name)
    error "More than one sketch specified" unless @options[:sketch_name].nil?
    @options[:sketch_name] = "dino_#{name}"
  end
end
