module Dino
  module Behaviors
    module State
      def initialize(options={})
        @state_mutex = Mutex.new
        @state = nil
      end
      
      def state
        @state_mutex.synchronize { @state }
      end
      
      protected

      def state=(value)
        @state_mutex.synchronize { @state = value }
      end
    end
  end
end
