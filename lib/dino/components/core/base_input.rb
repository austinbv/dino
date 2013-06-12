module Dino
  module Components
    module Core
      class BaseInput < Base
        attr_reader :state

        def initialize(options={})
          super options

          remove_callbacks
          self.mode = :in
          board.add_input_hardware(self)
          board.start_read

          after_initialize(options)
        end
        
        def read(&block)
          add_callback(:read, &block) if block_given?
          poll
        end
        
        def listen(&block)
          add_callback(:listen, &block) if block_given?
          start_listening
        end

        #
        # Define these in your subclass.
        # Should correspond to Board#digital_read, Board#digital_listen for digital
        # and Board#analog_read, Board#analog_listen for analog components. 
        #
        def poll ; end
        def start_listening ; end

        def add_callback(key=nil, &block)
          key ||= :persistent
          @callbacks[key] ||= []
          @callbacks[key] << block
        end

        alias :on_data :add_callback

        def remove_callback(key=nil)
          key ? @callbacks[key] = nil : @callbacks = {}
        end

        alias :remove_callbacks :remove_callback

        def stop_listening
          board.stop_listener(pin)
          remove_callback :listen
        end

        def update(data)
          @state = data
          @callbacks.each_value do |array|
            array.each { |callback| callback.call(@state) }
          end
          remove_callback :read
        end
      end
    end
  end
end
