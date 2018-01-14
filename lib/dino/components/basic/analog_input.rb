module Dino
  module Components
    module Basic
      class AnalogInput
        include Setup::SinglePin
        include Setup::Input
        include Mixins::Reader
        include Mixins::Poller
        include Mixins::Listener
        
        def _read
          board.analog_read(self.pin)
        end

        def _listen(divider=16)
          divider ||= 16
          board.analog_listen(self.pin, divider)
        end
      end
    end
  end
end
