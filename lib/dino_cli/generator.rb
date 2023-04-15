class DinoCLI::Generator
  require "fileutils"
  require "dino_cli/packages"
  require "dino_cli/targets"
  require "dino/version"
  
  require "dino_cli/helper"
  include DinoCLI::Helper
  
  attr_accessor :options

  def initialize(options={})
    @options = options
    append_target
  end

  def append_target
    options[:target] = :mega unless options[:target]
    # Preserve the source sketch name, since we need to copy that file.
    options[:src_sketch_name] = options[:sketch_name].dup
    options[:sketch_name] << "_#{options[:target]}" unless options[:target] == :mega
    options[:sketch_name] << "_#{::Dino::VERSION}"
  end

  def self.run!(options={})
    instance = self.new(options)

    instance.read
    instance.target_config
    instance.user_config
    instance.write
  end

  def read
    @packages = PACKAGES
    files_missing = false

    # Replace each filepath with a hash containing the filepath and contents.
    @packages.each_key do |k|
      @packages[k][:files].map! do |f|
        contents = File.read(File.join(options[:src_dir], "lib", f))
        #
        # Not using this anymroe. User has to install their own Arduino libraries.
        #
        # If the file is in src/vendor, it gets wrapped in an #ifdef
        # corresponding to the package directive. The entire package can now
        # be toggled in DinoDefines.h. Without this, IDE would try to compile anyway.
        # if f.match /\Avendor/
        #  directive = @packages[k][:directive]
        #  contents = "#include \"DinoDefines.h\"\n#ifdef #{directive}\n" << contents << "\n#endif\n"
        # end
        { path: f, contents: contents }
      rescue
        files_missing = true
        puts "File missing: #{f}"
      end
    end
    
    # Show the text file when vendor files are missing
    if files_missing
      missing_files
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

    # Define the DINO VERSION
    gsub_defines("#define DINO_VERSION __VERSION__", "#define DINO_VERSION \"#{::Dino::VERSION}\"");
  end

  def define(directive)
    gsub_defines "// #define #{directive}", "#define #{directive}"
  end

  # Run gsub! on contents of src/lib/Dino.h specifically.
  def gsub_defines(from, to)
    @packages[:core][:files].each do |f|
      if f[:path].match /DinoDefines.h/
        f[:contents].gsub!(from, to)
      end
    end
  end

  def write
    # Write the sketch itself first.
    sketch = File.join(output_dir, sketch_filename)
    File.open(sketch, 'w') { |f| f.write @sketch }

    # Go through the @packages hash and copy source files.
    # Exclude only for target hardware incompatibility.
    # Eg. ESP8266 IR library is different and incompatible with AVR version.
    @packages.each_key do |k|
      # Check if the package should be included for this target.
      package = @packages[k]
      targeted = !package[:only] || package[:only].include?(options[:target])
      excluded = package[:exclude] && package[:exclude].include?(options[:target])

      # Append source file basename to the output dir to get output file path.
      # Then write the file contents to the destination path.
      if (targeted && !excluded)
        package[:files].each do |file|
          next unless file
          dest_path = File.join(output_dir, file[:path].split('/')[-1])
          File.open(dest_path, 'w') { |f| f.write file[:contents] }
        end
      end
    end

    # Return the location of the sketch file.
    options[:sketch_file] = sketch
    options[:sketch_folder] = output_dir
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
