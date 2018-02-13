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
          @callback_mutex.synchronize {
            @callbacks[key] ||= []
            @callbacks[key] << block
          }
        end

        def remove_callback(key=nil)
          @callback_mutex.synchronize {
            key ? @callbacks.delete(key) : @callbacks = {}
          }
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

        #
        # Values received by #update are usually idempotent, i.e. the new state
        # of the component, and can pass to callbacks as-is. But some components
        # input a state change instead. Eg. rotary encoders with +1 or -1 steps.
        #
        # To maintain the pattern of callbacks receiving new state, while leaving
        # old state in the instance variable for comparison, we may want to
        # calculate the new state from a change input, and pass that instead.
        # Override this method to do so. See RotaryEncoder class for an example.
        #
        def pre_callback_filter(data)
          data
        end

        #
        # Assign data to @state automatically after callbacks by default.
        #
        # Override this to add behavior not matching this pattern, such as
        # components where data cannot be directly assigned to @state.
        # Eg. data is a hash, and value from a specific key reflects @state.
        # See RotaryEncoder class for an example.
        #
        def update_self(data)
          @state = data
        end
      end
    end
  end
end
