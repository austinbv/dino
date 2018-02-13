module Dino
  module Components
    class DHT
      include Setup::SinglePin
      include Setup::Input
      include Mixins::Poller

      def after_initialize(options={})
        super(options)
        @state = {temperature: nil, humidity: nil}
      end

      def _read
        board.dht_read(self.pin)
      end

      # Process raw data from the board before running #update.
      def pre_callback_filter(data)
        t, h = data.split(",")
        { temperature: t.to_f, humidity: h.to_f }
      end
    end
  end
end
