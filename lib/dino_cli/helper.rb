module DinoCLI::Helper
  def error(message, help=:usage)
    $stderr.puts
    $stderr.puts "Error: #{message}"
    $stderr.puts
    usage if help == :usage
    targets if help == :targets
  end

  def usage
    text = File.read(File.join(@options[:cli_dir], "usage.txt"))
    $stderr.print text
    $stderr.puts
    exit(2)
  end

  def targets
    text = File.read(File.join(@options[:cli_dir], "targets.txt"))
    $stderr.print text
    $stderr.puts
    exit(2)
  end
end
