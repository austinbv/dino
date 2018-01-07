module Dino
  module Components
    class DHT
      include Setup::SinglePin
      include Setup::Input
      include Mixins::Poller

      def after_initialize(options={})
        super(options) if defined?(super)
        @state = {temperature: nil, humidity: nil}
      end

      def _read
        board.dht_read(self.pin)
      end

      # Process raw data from the board before running Callbacks#update.
      # super will write to @state after running callbacks.
      def update(data)
        t, h = data.split(",")
        reading = { temperature: t.to_f, humidity: h.to_f }
        super(reading)
      end
    end
  end
end
