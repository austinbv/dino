module Dino
  module Components
    module Mixins
      module Callbacks
        def after_initialize(options={})
          super(options)
          @callbacks = {}
          @callback_mutex = Mutex.new
        end

        def add_callback(key=:persistent, &block)
          @callback_mutex.synchronize do
            @callbacks[key] ||= []
            @callbacks[key] << block
          end
        end

        def remove_callback(key=nil)
          @callback_mutex.synchronize do
            key ? @callbacks.delete(key) : @callbacks = {}
          end
        end

        alias :on_data :add_callback
        alias :remove_callbacks :remove_callback

        def update(data)
          data = pre_callback_filter(data)
          @callback_mutex.synchronize do
            @callbacks.each_value do |array|
              array.each { |callback| callback.call(data) }
            end
            # Remove the special :read callback while still inside the lock.
            @callbacks.delete(:read)
          end
          update_self(data)
        end

        # Override this to process data before passing to callbacks.
        def pre_callback_filter(data)
          data
        end

        # Set @state to the value passed to callbacks after running them all.
        # Override if some other behavior is needed.
        def update_self(data)
          @state = data
        end
      end
    end
  end
end
