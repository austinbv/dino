module Dino
  module API
    module DHT
      include Helper

      # CMD = 13
      def dht_read(pin)
        write Message.encode command: 13, pin: convert_pin(pin)
      end
    end
  end
end
