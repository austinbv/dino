module Dino
  module Behaviors
    module BusPeripheral
      include Component

      attr_reader :address
      alias  :bus :board

      def before_initialize(options={})
        options[:board] ||= options[:bus]
        super(options)
      end

      def atomically(&block)
        bus.mutex.synchronize do
          block.call
        end
      end
    end
  end
end
