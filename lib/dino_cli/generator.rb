class DinoCLI::Generator
  require "fileutils"
  require "dino_cli/packages"
  require "dino_cli/targets"
  attr_accessor :options

  def initialize(options={})
    @options = options
    append_target
  end

  def append_target
    # Default to generating the mega sketch.
    options[:target] = :mega unless options[:target]
    # Preserve the source sketch name, since we need to copy that file.
    options[:src_sketch_name] = options[:sketch_name].dup
    # Append the target to the output sketch name/folder when not using :mega.
    options[:sketch_name] << "_#{options[:target]}" unless options[:target] == :mega
  end

  def self.run!(options={})
    instance = self.new(options)

    instance.read
    instance.target_config
    instance.user_config
    instance.write
  end

  def read
    # Start by just copying the PACKAGES hash.
    @packages = PACKAGES

    # Now replace each filepath with a hash containing the filepath and contents.
    @packages.each_key do |k|
      @packages[k][:files].map! do |f|
        contents = File.read(File.join(options[:src_dir], f))
        # If the file is in src/vendor, it gets wrapped in an #ifdef
        # corresponding to the package directive. The entire package can now
        # be toggled in DinoDefines.h. Without this, IDE would try to compile anyway.
        if f.match /\Avendor/
          directive = @packages[k][:directive]
          contents = "#include \"DinoDefines.h\"\n#ifdef #{directive}\n" << contents << "\n#endif\n"
        end
        { path: f, contents: contents }
      end
    end

    # Read in the sketch itself.
    @sketch = File.read File.join(options[:src_dir], "#{options[:src_sketch_name]}.ino")
  end

  def user_config
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
      define("debug")
    end
    unless serial?
      define("TXRX_SPI")
    end
  end

  def target_config
    target_packages = TARGETS[options[:target]]
    target_packages.each do |t|
      directive = PACKAGES[t][:directive]
      define(directive) if directive
    end
  end

  def define(directive)
    gsub_defines "// #define #{directive}", "#define #{directive}"
  end

  # Run gsub! on contents of src/lib/Dino.h specifically.
  def gsub_defines(from, to)
    @packages[:core][:files].each do |f|
      if f[:path] == "lib/DinoDefines.h"
        f[:contents].gsub!(from, to)
      end
    end
  end

  def write
    # Write the sketch itself first.
    sketch = File.join(output_dir, sketch_filename)
    File.open(sketch, 'w') { |f| f.write @sketch }

    # Go through the @packages hash and copy all the source files regardless of target.
    # Append source file basename to the output dir to get output file path.
    # Then write the file contents to the destination path.
    @packages.each_key do |k|
      @packages[k][:files].each do |file|
        dest_path = File.join(output_dir, file[:path].split('/')[-1])
        File.open(dest_path, 'w') { |f| f.write file[:contents] }
      end
    end

    # Return the location of the sketch file.
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
    "#{options[:sketch_name]}.ino"
  end
end
