module Dino
  module TxRx
    class HandshakeAttempt
      attr_reader :acknowledged, :result
      def initialize
        @acknowledged = false
        @result = nil
      end

      def update(sender, result)
        @acknowledged = true
        sender.delete_observer(self)
        @result = result
      end
    end

    module Handshake
      HANDSHAKE_TRIES = 3
      HANDSHAKE_TIMEOUT = 2

      def handshake
        io_reset
        HANDSHAKE_TRIES.times do |retries|
          begin
            print "Sending handshake to: #{self.to_s}... "
            self.add_observer(attempt = HandshakeAttempt.new)
            write Dino::Message.encode(command: 90)

            Timeout.timeout(HANDSHAKE_TIMEOUT) do
              loop do
                if attempt.acknowledged
                  puts "Acknowledged. Hardware ready...\n\n"
                  return attempt.result
                end
              end
            end
          rescue Timeout::Error
            self.delete_observer(attempt)
            print "No response, "
            puts (retries + 1 < HANDSHAKE_TRIES ? "retrying..." : "exiting...")
            next
          end
        end
        raise HandshakeError, "Connected to wrong device, or device not running dino"
      end
    end
  end
end
