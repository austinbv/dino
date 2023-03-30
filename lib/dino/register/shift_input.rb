module Dino
  module Register
    class ShiftInput
      include Input
      include Behaviors::MultiPin
      #
      # Model registers that use the arduino shift functions as multi-pin
      # components, specifying clock, data and latch pins.
      #
      # options = board: my_board,
      #           pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
      #
      def initialize_pins(options={})
        proxy_pin :clock, DigitalIO::Output
        proxy_pin :data,  DigitalIO::Input
        proxy_pin :latch, ChipSelect
      end

      def before_initialize(options={})
        super(options)
        self.rising_clock = options[:rising_clock] || false
        self.bit_order = options[:bit_order] || :msbfirst
      end
      
      def after_initialize(options={})
        super(options)
        bubble_callbacks
      end

      #
      # Some registers use rising edges for clock signals. Unless we pull clock
      # pin high before each read, bits in the value will be out of position.
      # Set this once and future calls to #read and #listen will do it.
      #
      attr_reader :rising_clock
      attr_accessor :bit_order

      def rising_clock=(value)
        @rising_clock = [0, nil, false].include?(value) ? false : true
      end

      def read
        board.shift_read latch.pin, data.pin, clock.pin, @bytes, 
                          preclock_high: rising_clock,
                          bit_order: bit_order
      end

      def listen
        board.shift_listen latch.pin, data.pin, clock.pin, @bytes,
                            preclock_high: rising_clock,
                            bit_order: bit_order
      end

      def stop
        board.shift_stop(latch.pin)
      end
      
      # Reads come through the latch pin. Bubble them up to ourselves.
      def bubble_callbacks
        proxies[:latch].add_callback do |byte|
          self.update(byte)
        end
      end
    end
  end
end