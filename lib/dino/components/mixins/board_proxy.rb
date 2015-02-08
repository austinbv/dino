module Dino
  module Components
    module Mixins
      module BoardProxy
        def after_initialize(options={})
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
      end
    end
  end
end
