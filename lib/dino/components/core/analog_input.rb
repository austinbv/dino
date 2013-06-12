module Dino
  module Components
    module Core
      class AnalogInput < BaseInput
        def poll
          board.analog_read(self.pin)
        end

        def start_listening
          board.analog_listen(self.pin)
        end
      end
    end
  end
end
