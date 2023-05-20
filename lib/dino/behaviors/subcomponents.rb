module Dino
  module Behaviors
    module Subcomponents
      def components
        @components ||= []
      end

      def add_component(component)
        components << component
      end

      def remove_component(component)
        deleted = components.delete(component)
        component.stop if deleted && component.methods.include?(:stop)
      end
    end
  end
end
