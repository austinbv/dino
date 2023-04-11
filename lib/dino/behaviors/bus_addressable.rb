module Dino
  module Behaviors
    module BusAddressable
      def before_initialize(options={})
        unless options[:address]
          raise ArgumentError,
                'missing Slave device address; try Bus#search first'
        end
        @address = options[:address]
        super(options)
      end
    end
  end
end
