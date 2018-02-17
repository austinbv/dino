module Dino
  module Components
    module Setup
      module Input
        include SinglePin
        attr_reader :pullup, :divider

        def pullup=(pullup)
          @pullup = pullup
          board.set_pullup(self.pin, pullup)
        end

        def _stop_listener
          board.stop_listener(pin)
        end

      protected
      
        def initialize_pins(options={})
          super(options)
          self.mode = :in
          self.pullup = options[:pullup]
        end
      end
    end
  end
end
