module Dino
  module Components
    module DHT
      class Temperature < Core::BaseInput
        #
        # These components work too slowly to poll often enough for a listener.
        #
        def listen; end

        def _read
          board.dht_read(self.pin, 0)
        end

        def update(data)
          return unless data.match /T/
          data.gsub!('T', '')
          super(data)
        end
      end

      class Humidity < Core::BaseInput
        #
        # These components poll too slowly to poll often enough for a listener.
        #
        def listen; end

        def _read
          board.dht_read(self.pin, 1)
        end

        def update
          return unless data.match /H/
          data.gsub!('T', '')
          super(data)
        end
      end
    end
  end
end
