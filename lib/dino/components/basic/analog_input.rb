module Dino
  module Components
    module Basic
      class AnalogInput
        include Setup::SinglePin
        include Setup::Input
        include Mixins::Reader
        include Mixins::Poller
        include Mixins::Listener
        
        def after_initialize(options={})
          super(options)
          @divider = 16
        end

        def _read
          board.analog_read(pin)
        end

        def _listen(divider=nil)
          @divider = divider || @divider
          board.analog_listen(pin, @divider)
        end
        
        def pre_callback_filter(value)
          value.to_i
        end
      end
    end
  end
end
