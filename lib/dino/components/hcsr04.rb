module Dino
  module Components
    class HCSR04
      include Setup::SinglePin
      include Setup::Input
      include Mixins::Poller

      def _read
        board.ultrasonic_read(self.pin)
      end
    end
  end
end
