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
          board.analog_read(pin)
        end

        def _listen(divider=16)
          @divider = divider || 16
          board.analog_listen(pin, @divider)
        end
      end
    end
  end
end
