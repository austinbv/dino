module Dino
  module Components
    module Core
      class Input < Base
        def initialize(options={})
          super options

          clear_callbacks
          board.add_input_hardware(self)
          board.start_read

          after_initialize(options)
        end

        def read(&block)
          add_callback(:read, &block) if block_given?
        end

        def listen(&block)
          add_callback(:listen, &block) if block_given?
        end

        def stop_listening
          board.stop_listener(pin)
          clear_callbacks[:listen]
        end

        def add_callback(key=nil, &block)
          key ||= :persistent
          @callbacks[key] ||= []
          @callbacks[key] << block
        end

        alias :on_data :add_callback

        def clear_callbacks(key=nil)
          key ? @callbacks[key] = nil : @callbacks = {}
        end

        def update(data)
          @callbacks.each_value do |array|
            array.each { |callback| callback.call(data) }
          end
          @callbacks[:read] = []
        end
      end
    end
  end
end
