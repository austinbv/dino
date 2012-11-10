module Dino
  module Components
    class Button < BaseComponent
      UP = "01"
      DOWN = "00"

      def after_initialize(options={})
        @down_callbacks, @up_callbacks, @state = [], [], UP

        self.board.add_digital_hardware(self)
        self.board.start_read
      end

      def down(&callback)
        @down_callbacks << callback
      end

      def up(&callback)
        @up_callbacks << callback
      end

      def update(data)
        return if data == @state
        @state = data

        case data
          when UP
            button_up
          when DOWN
            button_down
          else
            return
        end
      end

      private

      def button_up
        @up_callbacks.each do |callback|
          callback.call
        end
      end

      def button_down
        @down_callbacks.each do |callback|
          callback.call
        end
      end
    end
  end
end
