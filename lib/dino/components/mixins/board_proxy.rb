module Dino
  module Components
    module Mixins
      module BoardProxy
        def after_initialize(options={})
          super(options) if defined?(super)
          @high = 1
          @low = 0
          @components = []
        end

        attr_reader :high, :low, :components

        def add_component(component)
          @components << component
        end

        def remove_component(component)
          @components.delete(component)
        end

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
