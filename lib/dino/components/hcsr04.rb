module Dino
  module Components
    class HCSR04 < Core::BaseInput
      def _read
        board.ulstrasonic_read(self.pin)
      end
    end
  end
end
