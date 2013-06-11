module Dino
  module Components
    module Core
      class DigitalInput < Input
        HIGH = 1
        LOW = 0

        def initialize(options={})
          super options
          listen
        end

        def read(&block)
          super &block
          board.digital_read(pin)
        end

        def listen(&block)
          super &block
          board.digital_listen(pin)
        end

        def on_high(&block)
          add_callback(:high) do |data|
            block.call(data) if data == HIGH
          end
        end

        def on_low(&block)
          add_callback(:low) do |data|
            block.call(data) if data == LOW
          end
        end

        def update(data)
          super(@state = data.to_i)
        end
      end
    end
  end
end
