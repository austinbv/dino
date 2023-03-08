module Dino
  module Components
    module Mixins
      module Callbacks
        attr_reader :callback_mutex

        def after_initialize(options={})
          super(options)
          @callback_mutex = Mutex.new
          remove_callbacks
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
          filtered_data = pre_callback_filter(data)

          callback_mutex.synchronize do
            @callbacks.each_value do |array|
              array.each do |callback|
                callback.call(filtered_data)
              end
            end
            # Remove special :read callback before unlocking.
            @callbacks.delete(:read)
          end

          update_state(filtered_data)
        end

        # Override to process data before giving to callbacks and state.
        def pre_callback_filter(data)
          data
        end

        # Override for behavior other than @state = filtered data.
        def update_state(filtered_data)
          self.state = filtered_data
        end
      end
    end
  end
end
