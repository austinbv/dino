module Dino
  module Components
    module Setup
      module MultiPin
        #
        # Model complex components by allowing them to use multiple pins.
        # Pins may be "required" or not, and "proxied" or not.
        # Proxying a pin creates a single-pin component on that pin of the given
        # class and stores it in @proxies.
        #
        include Base
        attr_reader :pin, :pins, :pullups, :proxies

        # Return a hash with the state of each proxy component.
        def proxy_states
          hash = {}
          proxies.each_key do |key|
            hash[key] = self.proxies[key].state rescue nil
          end
          hash
        end

      protected

        attr_writer :pins, :pullups, :proxies

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          #
          # Requiring a pin simply raises an error if missing from options[:pins].
          # It will not automatically set up a subcomponent or do anything else.
          # This is useful for calling Arduino-native libraries, where we need
          # to say what pins we are using, but don't need to do more in Ruby.
          #
          def require_pins(*args)
            required_pins = self.class_eval('@@required_pins') rescue []
            required_pins = (required_pins + args).uniq
            self.class_variable_set(:@@required_pins, required_pins)
          end
          alias :require_pin :require_pins

          #
          # Proxying a pin models it as a single-pin component and requires it.
          # It can be made optional by adding `optional: true` to the hash.
          #
          # When instancing a multi-pin component, its proxy instances are
          # created and stored in @proxies, readable via `#proxies`.
          #
          # A convenience method for each proxy is defined on the singleton
          # class of the multi-pin instance. For example, `rgb_led.red` returns
          # the AnalogOutput instance for the red part of that specific RGB LED.
          #
          # Method names match the hash keys (pin names) used when calling
          # '::proxy_pins' in the class definition. See RgbLed class for examples.
          #
          def proxy_pins(options={})
            if options[:optional]
              options.reject! { |k| k == :optional }
            else
              options.reject! { |k| k == :optional } if (options[:optional] == false)
              require_pins(*options.keys)
            end

            proxied_pins = self.class_eval('@@proxied_pins') rescue {}
            proxied_pins.merge!(options)
            self.class_variable_set(:@@proxied_pins, proxied_pins)
          end
          alias :proxy_pin :proxy_pins
        end

        def initialize_pins(options={})
          self.pins = options[:pins]
          self.pullups = options[:pullups] || {}
          self.proxies = {}
          validate_pins
          build_proxies
        end

        def validate_pins
          required_pins = self.class.class_eval('@@required_pins') rescue []
          required_pins.each { |key| raise "missing pins[:#{key}] pin" unless pins[key] }
        end

        def build_proxies
          proxied_pins = self.class.class_eval('@@proxied_pins') rescue {}
          proxied_pins.each_pair do |key, klass|
            component = klass.new(board: board, pin: pins[key], pullup: pullups[key]) rescue nil
            self.proxies[key] = component
            instance_variable_set("@#{key}", component)
            singleton_class.class_eval { attr_reader key }
          end
        end
      end
    end
  end
end
