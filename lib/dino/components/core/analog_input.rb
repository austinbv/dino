module Dino
  module Components
    module Core
      class AnalogInput < BaseInput
        def _read
          board.analog_read(self.pin)
        end

        def _listen
          board.analog_listen(self.pin)
        end
      end
    end
  end
end
