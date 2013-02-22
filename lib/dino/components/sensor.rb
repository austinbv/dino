module Dino
  module Components
    class Sensor < BaseComponent
      def after_initialize(options={})
        @data_callbacks = []
        @board.add_analog_hardware(self)
        @board.start_read
      end

      def when_data_received(&block)
        @data_callbacks << block
      end

      def update(data)
        @data_callbacks.each do |callback|
          callback.call(data)
        end
      end
    end
  end
end
