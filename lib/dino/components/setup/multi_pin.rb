module Dino
  module Components
    module Setup
      module MultiPin
        #
        # Model complex components, using multiple pins, by using proxy components
        # with one pin each. 
        #
        include Base
        attr_reader :pins, :proxies
        
        # Return a hash with the state of each proxy component.
        def proxy_states
          hash = {}
          proxies.each_key do |key|
            hash[key] = self.proxies[key].state rescue nil
          end
          hash
        end
        
        def before_initialize(options={})
          # Get given pins early. Avoids giving them again to require or proxy.
          self.pins = options[:pins]
          self.proxies = {}
          super(options)
        end
        
        #
        # Proxy a pin to a single-pin component. Set this up in the including
        # component's #initialize_pins method. Additional options for each proxy
        # (eg. pullup/pulldown) can be injected there.
        # 
        def proxy_pin(name, klass, pin_options={})
          # Proxied pins are required by default.
          require_pin(name) unless pin_options[:optional]
      
          # Make the proxy, passing through options, and store it.
          if self.pins[name]
            proxy = klass.new pin_options.merge(board: self.board, pin: self.pins[name])          
            self.proxies[name] = proxy
            instance_variable_set("@#{name}", proxy)
          end

          # Accessor for the proxy's instance var, or nil, if not given.
          singleton_class.class_eval { attr_reader name }
        end
        
        #
        # Require a single pin that may or may not be proxied. This is useful for
        # components using libraries running on the board, where we need to specify
        # the pin, but not do anything with it.
        #
        def require_pin(name)
          raise ArgumentError, "missing :#{name} pin" unless self.pins[name]
        end
  
        def require_pins(*array)
          [array].flatten.each { |name| require_pin(name) }
        end
        
        private
        
        attr_writer :pins, :proxies
      end
    end
  end
end
