module Dino
  module Components
    module Mixins
      module BoardProxy
        include BusMaster

        def after_initialize(options={})
          super(options)
          @high = 1
          @low = 0
        end

        attr_reader :high, :low

        def convert_pin(pin)
          pin = pin.to_i
        end

        def set_pin_mode(pin, mode)
          nil
        end

        def set_pullup(pin, pullup)
          nil
        end

        def start_read; end
      end
    end
  end
end
