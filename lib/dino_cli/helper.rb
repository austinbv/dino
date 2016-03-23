module DinoCLI::Helper
  def error(message)
    $stderr.puts
    $stderr.puts "Error: #{message}"
    $stderr.puts
    usage
  end

  def usage
    $stderr.puts "Usage:"
    $stderr.puts "  dino task [options]"
    $stderr.puts
    $stderr.puts "Tasks:"
    $stderr.puts "  sketch SKETCH [options]"
    $stderr.puts
    $stderr.puts "Available sketches and options for each sketch:"
    $stderr.puts
    $stderr.puts "  serial"
    $stderr.puts "    -baud BAUD"
    $stderr.puts "    -debug"
    $stderr.puts
    $stderr.puts "  ethernet"
    $stderr.puts "    -mac XX:XX:XX:XX:XX:XX"
    $stderr.puts "    -ip XXX.XXX.XXX.XXX"
    $stderr.puts "    -port PORT"
    $stderr.puts "    -debug"
    $stderr.puts
    $stderr.puts "  wifi"
    $stderr.puts "    -ssid SSID"
    $stderr.puts "    -password PASSWORD"
    $stderr.puts "    -port PORT"
    $stderr.puts "    -debug"
    $stderr.puts
    $stderr.puts "Example:"
    $stderr.puts
    $stderr.puts "  dino sketch serial -baud 9600"
    $stderr.puts
    exit(2)
  end
end
