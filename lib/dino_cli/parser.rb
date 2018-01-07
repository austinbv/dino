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
    # Ensure we have arguments.
    args = @options[:args].dup
    error("No arguments given") if args.empty?

    # Ensure task is the first argument.
    @options[:task] = args.shift

    # If the task is a help command, just run it, don't return.
    usage if @options[:task].match /help|usage/
    targets if @options[:task].match /targets/

    # Ensure there's only one task
    error "Invalid task '#{@options[:task]}'" unless DinoCLI::TASKS.include? @options[:task]

    # Parse the rest loosely.
    loop do
      case args[0]
        when 'serial'
          args.shift; set_sketch("serial")
        when 'ethernet'
          args.shift; set_sketch("ethernet")
        when 'wifi'
          args.shift; set_sketch("wifi")
        when '-baud'
          args.shift; @options[:baud] = args.shift
        when '-target'
          args.shift; set_target(args.shift)
        when '-mac'
          args.shift; @options[:mac] = args.shift
        when '-ip'
          args.shift; @options[:ip] = args.shift
        when '-ssid'
          args.shift; @options[:ssid] = args.shift
        when '-password'
          args.shift; @options[:password] = args.shift
        when '-port'
          args.shift; @options[:port] = args.shift
        when '-debug'
          args.shift; @options[:debug] = true
        when /^-/
          error "Invalid argument '#{args[0]}'"
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

  def set_target(target)
    targets = DinoCLI::Generator::TARGETS.each_key.map{|a| a.to_s}
    error "Invalid target '#{target}'", :targets unless targets.include?(target)
    @options[:target] = target.to_sym
  end
end
