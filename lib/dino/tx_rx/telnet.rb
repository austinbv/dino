require 'net/telnet'
require 'observer'

module Dino
  module TxRx
    class Telnet
      include Observable

      def initialize(host, port)
        @host, @port = host, port
        @read_buffer = ""
      end

      def io
        @io ||= connect
      end

      def read
        @thread ||= Thread.new do
          loop do
            io.waitfor("\n") do |text|
              @read_buffer += text
              while line = @read_buffer.slice!(/^.*\n/) do
                pin, message = line.chomp.split(/::/)
                pin && message && changed && notify_observers(pin, message)
              end
            end
            sleep 0.004
          end
        end
      end

      def close_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @read_buffer = ""
        @thread = nil
      end

      def write(message)
        io.puts(message)
      end

    private
    
      def connect
        Net::Telnet.new("Host" => @host, "Port" => @port)
      rescue
        raise BoardNotFound
      end
    end
  end
end
