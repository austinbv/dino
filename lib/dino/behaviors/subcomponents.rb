module Dino
  module Behaviors
    module Subcomponents
      def components
        @components ||= []
      end

      def single_pin_components
        @single_pin_components ||= {}
      end

      def add_component(component)
        components << component

        if component.respond_to?(:pin) && component.pin.class == Integer
          unless single_pin_components[component.pin]
            single_pin_components[component.pin] = component
          else
            raise StandardError,  "Error adding #{component} to #{self}. Pin: #{component.pin} " \
                                  "already in use by: #{single_pin_components[component.pin]}"
          end
        end
      end

      def remove_component(component)
        if component.respond_to?(:pin) && component.pin.class == Integer
          single_pin_components[component.pin] = nil
        end
        
        deleted = components.delete(component)
        component.stop if deleted && component.respond_to?(:stop)
      end
    end
  end
end
