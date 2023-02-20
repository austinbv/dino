module Dino
  module Components
    module Register
      class ShiftOut
        include Output
        #
        # Model registers that use the arduino shift functions as multi-pin
        # components, specifying clock, data and latch pins.
        #
        # options = board: my_board,
        #           pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
        #
        include Setup::MultiPin
        proxy_pins  clock: Basic::DigitalOutput,
                    data:  Basic::DigitalOutput,
                    latch: Register::Select
                    
        def before_initialize(options={})
          super(options)
          self.bit_order = options[:bit_order] || :lsbfirst
        end
        
        attr_accessor :bit_order

        def write(*bytes)
          board.shift_write(latch.pin, data.pin, clock.pin, bytes)
        end
      end
    end
  end
end
