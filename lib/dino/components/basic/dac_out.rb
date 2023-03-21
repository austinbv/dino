module Dino
  module Components
    module Basic
      class DACOut
        include Setup::SinglePin
        include Mixins::Callbacks
        include Mixins::Threaded
        
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
end
