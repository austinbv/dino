module Dino
  module Components
    module Mixins
      module Callbacks
        def after_initialize(options={})
          super(options) if defined?(super)
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
            key ? @callbacks[key] = [] : @callbacks = {}
          }
        end

        alias :on_data :add_callback
        alias :remove_callbacks :remove_callback

        def update(data)
          @callback_mutex.synchronize {
            @callbacks.each_value do |array|
              array.each { |callback| callback.call(data) }
            end
          }
          remove_callback :read
          @state = data
        end
      end
    end
  end
end
