module Dino
  module Behaviors
    module BusPeripheralAddressed
      include Dino::Behaviors::BusPeripheral

      def before_initialize(options={})
        unless options[:address]
          raise ArgumentError, "missing address for #{self}. Try Bus#search first"
        end
        @address = options[:address]
        super(options)
      end
    end
  end
end
