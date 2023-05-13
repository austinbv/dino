module Dino
  module SPI
    class BaseRegister
      include Peripheral
      #
      # Registers act as a Board for components that need only digital pins in
      # in their I/O direction. Give the register as a 'board' when initializing a
      # new component, and pin numbers that map onto the registers parallel output pins.
      #
      include Behaviors::BoardProxy

      attr_reader :bytes

      def before_initialize(options={})
        super(options)
        #
        # To use the register as a board proxy, we need to know how many
        # bytes there are and map each bit to a virtual pin.
        # Defaults to 1 byte. Ignore if writing to the register directly.
        #
        @bytes = options[:bytes] || 1
        #
        # When used as a board proxy, store the state of each register
        # pin as a 0 or 1 in an array that is (@bytes * 8) long. Zero out to start.
        #
        @state = Array.new(@bytes*8) { 0 }
      end

      def after_initialize(options={})
        super(options)

        # Drive select pin high by default.
        self.high
      end
    end
  end
end
