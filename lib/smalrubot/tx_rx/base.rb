require 'observer'
require 'timeout'

module Smalrubot
  module TxRx
    class Base
      def read(timeout = 0.005)
        line = gets(timeout)
        if line && line.match(/\A\d+:/)
          pin, message = line.chomp.split(/:/)
          if pin && message
            return pin, message
          end
        end
      end

      def write(message)
        n = io.write(message)
        Smalrubot.debug_log('write: %s(A:%d, E:%d)', message, n, message.length)
        if n != message.length
          raise "FATAL: n(#{n}) != message.length(#{message.length})"
        end
      end

      def handshake
        5.times do
          write("!9000000.")
          line = gets(1)
          if line && line.match(/ACK:/)
            flush_read
            return line.chomp.split(/:/)[1].to_i
          end
        end
      raise BoardNotFound
      end

      def flush_read
        gets until gets == nil
      end

      RETURN_CODE = "\n".ord

      def gets(timeout=0.005)
        Timeout.timeout(timeout) do
          s = io.gets
          Smalrubot.debug_log("gets: %s", s)
          return s
        end
      rescue Exception
        nil
      end
    end
  end
end
