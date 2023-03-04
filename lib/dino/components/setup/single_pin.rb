module Dino
  module Components
    module Setup
      module SinglePin
        include Base
        attr_reader :pin, :directon, :pull, :mode
        
        def mode=(mode)
          @direction = :input
          @direction = :output if [:out, :output].include? mode

          @pull = nil
          if @direction == :input
            @pull = :pullup if mode == :input_pullup
            @pull = :pulldown if mode == :input_pulldown
          end
          
          @mode = "#{@direction}"
          @mode << "_#{@pull}" if @pull
          @mode = @mode.to_sym
          
          board.set_pin_mode(pin, @direction, @pull)
        end
        
      protected

        attr_writer :pin

        def initialize_pins(options={})
          raise ArgumentError, 'a pin is required for this component' unless options[:pin]
          self.pin = options[:pin]
        end
      end
    end
  end
end
