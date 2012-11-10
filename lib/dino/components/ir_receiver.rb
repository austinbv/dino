module Dino
  module Components
    class IrReceiver < BaseComponent
      STABLE = "01"

      def after_initialize(options={})
        @flash_callbacks = []

        self.board.add_digital_hardware(self)
        self.board.start_read
      end

      def flash(callback)
        @flash_callbacks << callback
      end

      def update(data)
        return if data == STABLE
        light_flashed
      end

      private

      def light_flashed
        @flash_callbacks.each do |callback|
          callback.call
        end
      end
    end
  end
end
