module Dino
  module Components
    module Basic
      class DigitalInput
        include Setup::SinglePin
        include Setup::Input
        include Mixins::Reader
        include Mixins::Poller
        include Mixins::Listener

        def after_initialize(options={})
          super(options)
          _listen
        end

        def _read
          board.digital_read(pin)
        end

        def _listen(divider=4)
          @divider = divider
          board.digital_listen(pin, @divider)
        end

        def on_high(&block)
          add_callback(:high) do |data|
            block.call(data) if data.to_i == board.high
          end
        end

        def on_low(&block)
          add_callback(:low) do |data|
            block.call(data) if data.to_i == board.low
          end
        end
        
        def pre_callback_filter(data)
          data.to_i
        end

        def high?; state == board.high end
        def low?;  state == board.low  end
      end
    end
  end
end
