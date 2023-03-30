module Dino
  module Behaviors
    module OutputPin
      include SinglePin
      protected

      def initialize_pins(options={})
        super(options)
        self.mode = :output
      end
    end
  end
end
