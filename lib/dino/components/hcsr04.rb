module Dino
  module Components
    class HCSR04 < Core::BaseInput
      def _read
        board.ultrasonic_read(self.pin)
      end
    end
  end
end
