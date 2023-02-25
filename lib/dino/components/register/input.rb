module Dino
  module Components
    module Register
      module Input
        include Setup::Base
        include Mixins::Callbacks

        attr_reader :bytes
        
        def before_initialize(options={})
          super(options)
          #
          # To use the register as a board proxy, we need to know how many
          # bytes there are and map each bit to a virtual pin.
          # Defaults to 1 byte. Ignore if writing to the register directly.
          #
          @bytes = options[:bytes] || 1

          #
          # When used as a board proxy, store the state of each register
          # pin as a 0 or 1 in an array that is (@bytes * 8) long. Zero out to start.
          #
          @state = Array.new(@bytes*8) { 0 }

          #
          # Keep track of whether anything is listening or reading a specific pin.
          # This might be separate from whether a component is attached or not.
          #
          @reading_pins   = Array.new(@bytes*8) { false}
          @listening_pins = Array.new(@bytes*8) { false}
        end

        def after_initialize(options={})
          super(options)
          enable_proxy
        end

        #
        # Override Callbacks#update to make sure we handle :force_update
        # within the main mutex lock.
        #
        def update(message)
          bits = byte_array_to_bit_array(message.split(","))

          @callback_mutex.synchronize {
            #
            # The Arduino code does not de-duplicate repeated state.
            # Do it here, but if a :force_update callback exists, run anyway.
            #
            if (bits != @state)|| @callbacks[:force_update]
              @callbacks.each_value do |array|
                array.each { |callback| callback.call(bits) }
              end
            end

            # Remove both :read and :force update while inside the lock.
            @callbacks.delete(:read)
            @callbacks.delete(:force_update)
          }
          @state = bits
        end

        #
        # Convert an array of cached bytes into an array of integer 1s and 0s
        # Convenient for bubbling to proxy components, but is used for all callbacks.
        #
        def byte_array_to_bit_array(byte_array)
          byte_array.map do |byte|
            byte.to_i.to_s(2).rjust(8, "0").split("").reverse
          end.flatten.map { |bit| bit.to_i }
        end

        def read
          raise 'define #read in child class depending on communication method'
        end

        def listen
          raise 'define #listen in child class depending on communication method'
        end

        #
        # Make the register act as a board for components that need only digital
        # input pins. Pass the register as a 'board' and pin numbers such that pin 0
        # is the 1st bit of the 1st byte, pin 9 is 1st bit of the 2nd byte, and so on.
        #
        include Mixins::BoardProxy

        def digital_read(pin)
          #
          # Remember what pin was read and force callbacks to run next update.
          #
          add_callback(:force_update) { Proc.new{} }
          @reading_pins[pin] = true

          # Don't actually call #read if already listening.
          read unless any_listening
        end

        def digital_listen(pin, divider)
          listen unless any_listening
          @listening_pins[pin] = true
        end

        def stop_listener(pin)
          @listening_pins[pin] = false
          stop unless any_listening
        end

        def any_listening
          @listening_pins.each { |p| return true if p }
          false
        end

        def stop
          raise 'define #stop in child class to stop the listener'
        end

        #
        # Mimic Board#update, but in a callback fired through #update.
        # This doesn't interfere with using the register directly,
        # and doesn't fire if the board isn't acting as a proxy (no components).
        #
        def enable_proxy
          self.add_callback(:board_proxy) do |bit_array|
            bit_array.each_with_index do |value, pin|
              components.each do |part|
                update_component(part, pin, value) if pin == part.pin
              end
              @reading_pins[pin] = false
            end
          end
        end

        def update_component(part, pin, value)
          # Update if component is listening and value has changed.
          if @listening_pins[pin] && (value != @state[pin])
            part.update(value)
          # Also update if the component forced a read.
          elsif @reading_pins[pin] && @callbacks[:force_update]
            part.update(value)
          end
        end
      end
    end
  end
end
