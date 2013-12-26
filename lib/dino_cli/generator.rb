class DinoCLI::Generator
  require "fileutils"
  LIB_FILENAMES = ["Dino.h", "Dino.cpp", "DinoLCD.h", "DinoLCD.cpp", "DinoSerial.cpp","DinoSerial.h", "DHT.cpp", "DHT.h"]
  attr_accessor :options

  def initialize(options={})
    @options = options
  end

  def self.run!(options={})
    instance = self.new(options)

    instance.read
    instance.modify
    instance.write
  end

  def read
    @libs = LIB_FILENAMES.map do |f| 
      File.read(File.join(options[:src_dir], "lib", f))
    end
    @sketch = File.read File.join(options[:src_dir], sketch_filename)
  end

  def modify
    if options[:baud] && serial?
      @sketch.gsub! "115200", options[:baud]
    end
    if options[:mac] && ethernet?
      octets = @options[:mac].split(':')
      bytes = octets.map { |o| "0x#{o.upcase}" }
      @sketch.gsub! "{ 0xDE, 0xAD, 0xBE, 0x30, 0x31, 0x32 }", bytes.inspect.gsub("[", "{").gsub("]", "}").gsub("\"", "")
    end
    if options[:ip] && ethernet?
      @sketch.gsub! "192,168,0,77", options[:ip].gsub(".", ",")
    end
    if options[:ssid] && wifi?
      @sketch.gsub! "yourNetwork", options[:ssid]
    end
    if options[:password] && wifi?
      @sketch.gsub! "yourPassword", options[:password]
    end
    if options[:port]
      @sketch.gsub! "int port = 3466", "int port = #{options[:port]}"
    end
    if options[:debug]
      @libs[0].gsub! "// #define debug true", "#define debug true"
    end
  end

  def write
    sketch = File.join(output_dir, sketch_filename)
    File.open(sketch, 'w') { |f| f.write @sketch }

    libs = LIB_FILENAMES.map { |f| File.join(output_dir, f)}
    libs.each_with_index do |file, index|
      File.open(file, 'w') { |f| f.write @libs[index]}
    end

    options[:sketch_file] = sketch
    options
  end

  def output_dir
    options[:output_dir] ||= make_output_dir
  end

  def make_output_dir
    dir = File.join options[:working_dir], options[:sketch_name]
    Dir::mkdir(dir) unless File.directory?(dir)
    dir
  end

  %w(serial ethernet wifi).each do |sketch|
    define_method("#{sketch}?") do
      options[:sketch_name].match /#{sketch}/
    end
  end

  def sketch_filename
    options[:sketch_filename] ||= "#{options[:sketch_name]}.ino"
  end
end
