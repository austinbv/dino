module Dino
  module Components
    module Mixins
      module Callbacks
        def callbacks
          @callbacks ||= {}
        end

        def add_callback(key=:persistent, &block)
          callbacks
          @callbacks[key] ||= []
          @callbacks[key] << block
        end
        
        def remove_callback(key=nil)
          callbacks
          key ? @callbacks[key] = [] : @callbacks = {}
        end

        alias :on_data :add_callback
        alias :remove_callbacks :remove_callback

        def update(data)
          @state = data
          callbacks.each_value do |array|
            array.each { |callback| callback.call(@state) }
          end
          remove_callback :read
        end
      end
    end
  end
end
