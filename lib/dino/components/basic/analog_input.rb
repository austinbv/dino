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

        def _listen
          board.analog_listen(self.pin)
        end
      end
    end
  end
end
