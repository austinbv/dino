module Dino
  module Components
    module Setup
      module MultiPin
        #
        # Build complex components by modeling them as separate single pin subcomponents.
        #
        include Base
        attr_reader :pins, :pullups, :proxies

        #
        # Return a hash with the state of each proxy component.
        #
        def state
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

        #
        # A subcomponent's pin can be required, proxied, or both.
        #
        # Requiring a pin simply raises an error if a value for it is not specified in the options[:pins] hash.
        # It will NOT automatically set up a subcomponent or do anything further.
        # This can be useful for native libraries where modeling the pin as a subcomponent is not necessary.
        # Or for components with pins that may be left disconnected.
        #
        # Proxying a pin automatically requires it, and specifies what single-pin component it should be modeled as.
        # This module will automatically intialize the proxy component and store it in the @proxies instance variable.
        # It also creates an attr_accessor on the singleton class for the subcomponent.
        # The accessor and the hash element are both named using the pin's key from the options[:pins] hash.
        #
        # A proxied pin can be NOT required by including `optional: true` in the options hash passed to #proxy_pins.
        # Please see the source for the SSD and RgbLed components for good examples of how all this works.
        #
        module ClassMethods
          def require_pins(*args)
            required_pins = self.class_eval('@@required_pins') rescue []
            required_pins = (required_pins + args).uniq
            self.class_variable_set(:@@required_pins, required_pins)
          end
          alias :require_pin :require_pins

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
