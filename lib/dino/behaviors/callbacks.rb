module Dino
  module Behaviors
    module Callbacks
      include State
      attr_reader :callback_mutex

      def initialize(options={})
        @callback_mutex = Mutex.new
        remove_callbacks
        super(options)
      end

      def callbacks
        callback_mutex.synchronize { @callbacks }
      end

      def add_callback(key=:persistent, &block)
        callback_mutex.synchronize do
          @callbacks[key] ||= []
          @callbacks[key] << block
        end
      end

      def remove_callback(key=nil)
        callback_mutex.synchronize do
          key ? @callbacks.delete(key) : @callbacks = {}
        end
      end

      alias :on_data :add_callback
      alias :remove_callbacks :remove_callback

      def update(data)
        # nil will unblock #read without running callbacks.
        unless data
          remove_callback(:read)
          return nil
        end

        filtered_data = pre_callback_filter(data)

        # nil will unblock #read without running callbacks.
        unless filtered_data
          remove_callback(:read)
          return nil
        end

        callback_mutex.synchronize do
          @callbacks.each_value do |array|
            array.each do |callback|
              callback.call(filtered_data)
            end
          end
          # Remove one-time callbacks added by #read.
          @callbacks.delete(:read)
        end

        update_state(filtered_data)
      end

      # Override to process data before giving to callbacks and state.
      def pre_callback_filter(data)
        data
      end
    end
  end
end
