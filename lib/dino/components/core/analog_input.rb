module Dino
  module Components
    module Core
      class AnalogInput < Input
        def read(&block)
          super &block
          board.analog_read(pin)
        end

        def listen(&block)
          super &block
          board.analog_listen(pin)
        end
      end

      def update(data)
        super(data.to_i)
      end
    end
  end
end
