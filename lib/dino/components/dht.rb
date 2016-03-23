module Dino
  module Components
    module DHT
      class Temperature
        include Setup::SinglePin
        include Setup::Input
        include Mixins::Poller

        def _read
          board.dht_read(self.pin, 0)
        end

        def update(data)
          return unless data.match /T/
          data.gsub!('T', '')
          super(data.to_f)
        end
      end

      class Humidity
        include Setup::SinglePin
        include Setup::Input
        include Mixins::Poller

        def _read
          board.dht_read(self.pin, 1)
        end

        def update(data)
          return unless data.match /H/
          data.gsub!('H', '')
          super(data.to_f)
        end
      end
    end
  end
end
