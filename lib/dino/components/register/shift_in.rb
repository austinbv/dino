module Dino
  module Components
    module Register
      class ShiftIn
        include Input
        #
        # Model registers that use the arduino shift functions as multi-pin
        # components, specifying clock, data and latch pins.
        #
        # options = board: my_board,
        #           pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
        #
        include Setup::MultiPin
        proxy_pins  clock: Basic::DigitalOutput,
                    data:  Basic::DigitalInput,
                    latch: Register::Select

        def after_initialize(options={})
          super(options)
          self.rising_clock = options[:rising_clock]
          bubble_callbacks
        end

        #
        # Some registers use rising edges for clock signals. Unless we pull clock
        # pin high before each read, bits in the value will be out of position.
        # Set this once and future calls to #read and #listen will do it.
        #
        attr_reader :rising_clock

        def rising_clock=(value)
          @rising_clock = [0, nil, false].include?(value) ? false : true
        end

        # Reads come through the latch pin. Bubble them up to ourselves.
        def bubble_callbacks
          proxies[:latch].add_callback do |byte|
            self.update(byte)
          end
        end

        def read(num_bytes=@bytes)
          board.shift_read latch.pin, data.pin, clock.pin, num_bytes,
                           preclock_high: rising_clock
        end

        # Untested
        def listen(num_bytes=@bytes)
          board.shift_listen latch.pin, data.pin, clock.pin, num_bytes,
                             preclock_high: rising_clock
        end

        def stop
          board.shift_stop(latch.pin)
        end
      end
    end
  end
end
