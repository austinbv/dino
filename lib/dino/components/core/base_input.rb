module Dino
  module Components
    module Core
      class BaseInput < Base
        include Threaded

        def initialize(options={})
          super options

          remove_callbacks
          self.mode = :in
          board.add_input_hardware(self)

          after_initialize(options)
        end
        
        def read(&block)
          add_callback(:read, &block) if block_given?
          _read
          loop { break if @callbacks[:read].empty? }
        end
        
        def listen(&block)
          add_callback(:listen, &block) if block_given?
          _listen
        end

        def poll(interval, &block)
          add_callback(:poll, &block) if block_given?
          threaded_loop do
            _read; sleep interval
          end
        end

        def stop
          stop_thread
          board.stop_listener(pin)
          remove_callback :listen; remove_callback :poll
        end

        #
        # Defined in DigitalInput and AnalogInput subclasses.
        # _read corresponds to Board#digital_read and Board#analog_read respectively.
        # _listen corresponds to Board#digital_listen and Board#analog_listen respectively
        #
        def _read; end
        def _listen; end

        def add_callback(key=nil, &block)
          key ||= :persistent
          @callbacks[key] ||= []
          @callbacks[key] << block
        end
        
        def remove_callback(key=nil)
          key ? @callbacks[key] = [] : @callbacks = {}
        end

        alias :on_data :add_callback
        alias :remove_callbacks :remove_callback

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
