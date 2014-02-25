module Dino
  module Components
    class DS18B20
      include Setup::SinglePin
      include Setup::Input
      include Mixins::Poller

      def _read
        board.ds18b20_read(self.pin, 0)
      end
    end
  end
end
