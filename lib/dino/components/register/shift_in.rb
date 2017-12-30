module Dino
  module Components
    module Register
      class ShiftIn
        include Input
        #
        # Model registers that use the arduino shift functions as multi-pin
        # components, specifying clock, data and latch pins.
        #
        # options = {board: my_board, pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
        #
        include Setup::MultiPin
        proxy_pins  clock: Basic::DigitalOutput,
                    data:  Basic::DigitalInput,
                    latch: Register::Select

        #
        # Data will arrive on the latch pin, similar to an analog read.
        # Bubble it up to the register object (self), then deal with it there.
        #
        def after_initialize(options={})
          super(options) if defined?(super)
          bubble_callbacks
        end

        def bubble_callbacks
          proxies[:latch].add_callback do |byte|
            self.update(byte)
          end
        end

        #
        # Read using the native shiftIn function of the Arduino library.
        #
        def read
          # Pack the extra parameters we need to send in the aux message then send.
          aux = [data.pin, clock.pin, @preclock_high].pack('C*')
          board.write Dino::Message.encode(command: 23, pin: latch.pin, value: @bytes, aux_message: aux)
        end

        def listen
          # Pack the extra parameters we need to send in the aux message then send.
          aux = [data.pin, clock.pin, @preclock_high].pack('C*')
          board.write Dino::Message.encode(command: 26, pin: latch.pin, value: @bytes, aux_message: aux)
        end

        def stop
          # Just need to send the latch pin to stop listening.
          board.write Dino::Message.encode(command: 28, pin: latch.pin)
        end
      end
    end
  end
end
