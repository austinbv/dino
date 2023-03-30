module Dino
  module AnalogIO
    class Output
      include Behaviors::OutputPin
      include Behaviors::Callbacks
      include Behaviors::Threaded
      
      interrupt_with :write
      
      def initialize_pins(options={})
        super(options)
        self.mode = :output_dac
      end

      def write(value)
        board.dac_write(pin, @state = value)
      end
    end
  end
end
