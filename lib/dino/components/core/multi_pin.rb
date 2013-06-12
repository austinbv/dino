module Dino
  module Components
    module Core
      class MultiPin
        attr_reader :board, :pins, :pullups

        def initialize(options={})
          raise 'board and pins are required for a component' if options[:board].nil? || options[:pins].nil?

          self.board = options[:board]
          self.pins = options[:pins]
          self.pullups = options[:pullups] || {}
          
          after_initialize(options)
        end

        def state
          state = {}
          pins.each_key do |pin|
            state[pin] = self.send(pin).state
          end
          state
        end

        protected

        attr_writer :board, :pins, :pullups

        #
        # @note This method should be implemented in your subclass.
        #
        def after_initialize(options={}) ; end

        #
        # Build complex components by proxying each pin to a basic, single pin component.
        #
        # Call #proxy with a hash like:
        #   class MyComponent < MultiPin
        #     proxy {lamp: Core::BaseOutput, motor: Core::BaseOutput}
        #   end
        #
        # Checks the @pins hash for the pins corresponding to the keys like:
        #   pins => {lamp: 9, motor: 10}  - No error
        #   pins => {lamp: 9}             - Error raised
        #
        # It instantiates a new instance of the class passed in for each key in an instance variable.
        # Sets up an attr_reader on the singleton class, so the proxy component can be accessed like:
        #   my_component.lamp.on; my_component.motor.analog_write(128) 
        # 
        def proxy(proxies={})
          proxies.each_pair do |key, klass|
            raise "missing pins[:#{key}] pin" unless pins[key]

            proxy_component = klass.new(board: board, pin: pins[key], pullup: pullups[key])
            instance_variable_set("@#{key}", proxy_component)

            singleton_class.class_eval { attr_reader key }
          end
        end

        alias :proxies :proxy
      end
    end
  end
end
