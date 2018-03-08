module Dino
  module Components
    module Mixins
      module Callbacks
        attr_reader :callback_mutex, :callbacks
        attr_writer :callbacks

        def after_initialize(options={})
          super(options)
          @callbacks = {}
          @callback_mutex = Mutex.new
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
          data = pre_callback_filter(data)

          callback_mutex.synchronize do
            callbacks.each_value do |array|
              array.each do |callback|
                callback.call(data)
              end
            end
            # Remove special :read callback before unlocking.
            callbacks.delete(:read)
          end

          update_self(data)
        end

        # Override this to process data before passing to callbacks.
        def pre_callback_filter(data)
          data
        end

        # Override if behavior other than @state = filtered data is needed.
        def update_self(filtered_data)
          self.state = filtered_data
        end
      end
    end
  end
end
