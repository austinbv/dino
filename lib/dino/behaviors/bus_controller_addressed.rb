module Dino
  module Behaviors
    module BusControllerAddressed
      include BusController

      def add_component(component)
        addresses = components.map { |c| c.address }
        if addresses.include? component.address
          raise ArgumentError, "duplicate peripheral address for #{component}"
        end
        super(component)
      end
    end
  end
end
