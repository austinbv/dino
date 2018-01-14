module Dino
  module Components
    module Setup
      module Input
        attr_reader :pullup

        def pullup=(pullup)
          @pullup = pullup
          board.set_pullup(self.pin, pullup)
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
