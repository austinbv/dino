module DinoCLI::Helper
  def error(message)
    $stderr.puts
    $stderr.puts "Error: #{message}"
    $stderr.puts
    usage
  end

  def usage
    $stderr.puts "Usage:"
    $stderr.puts "  dino COMMAND [command-specific-options]"
    $stderr.puts
    $stderr.puts "Commands:"
    $stderr.puts "  generate-sketch SKETCH [options]"
    $stderr.puts
    $stderr.puts "    Available sketches and options:"
    $stderr.puts
    $stderr.puts "      serial"
    $stderr.puts "        --baud BAUD"
    $stderr.puts "        --debug"
    $stderr.puts "        --upload"
    $stderr.puts
    $stderr.puts "      ethernet"
    $stderr.puts "        --mac XX:XX:XX:XX:XX:XX"
    $stderr.puts "        --ip XXX.XXX.XXX.XXX"
    $stderr.puts "        --port PORT"
    $stderr.puts "        --debug"
    $stderr.puts "        --upload"
    $stderr.puts
    $stderr.puts "      wifi"
    $stderr.puts "        --ssid SSID"
    $stderr.puts "        --password PASSWORD"
    $stderr.puts "        --port PORT"
    $stderr.puts "        --debug"
    $stderr.puts "        --upload"
    $stderr.puts
    $stderr.puts "Note: Automatic upload requires Arduino IDE 1.5 or greater."
    $stderr.puts "      Set your board type and serialport in the IDE first."
    $stderr.puts
    exit(2)
  end
end
