module Dino
  module Behaviors
    module BusController
      include Subcomponents

      def mutex
        @mutex ||= Mutex.new
      end
    end
  end
end
