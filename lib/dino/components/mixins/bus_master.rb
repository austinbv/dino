module Dino
  module Components
    module Mixins
      module BusMaster
        def mutex
          @mutex ||= Mutex.new
        end

        # Essential part of board interface that components need.
        attr_reader :components

        def add_component(component)
          @components ||= []
          @components << component
        end

        def remove_component(component)
          @components.delete(component)
        end
      end
    end
  end
end
