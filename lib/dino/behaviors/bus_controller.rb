module Dino
  module Behaviors
    module BusController
      def mutex
        @mutex ||= Mutex.new
      end

      # Essential part of board interface that components need.
      def components
        @components ||= []
      end

      def add_component(component)
        components << component
      end

      def remove_component(component)
        components.delete(component)
      end
    end
  end
end
