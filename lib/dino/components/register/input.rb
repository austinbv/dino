module Dino
  module Components
    module Register
      module Input
        include Setup::Base
        include Mixins::Callbacks

        def after_initialize(options={})
          super(options) if defined?(super)
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
          @state = Array.new(@bytes*8) {|i| 0}

          #
          # Certain registers which use rising edges for clock signals produce
          # errors with the native Arduino shiftIn function unless you set the clock
          # pin high before reading. Setting this instance var to 1 will include
          # that instruction on every call to read or listen.
          #
          @preclock_high = options[:preclock_high] ? 1 : 0

          enable_proxy
        end

        #
        # Callbacks#update mostly works, but we need to convert the state from
        # comma delimited numbers into an array of bits first.
        #
        def update(message)
          bits = byte_array_to_bit_array(message.split(","))
          super(bits)
        end

        #
        # Convert an array of cached bytes into an array of integer 1s and 0s
        # Convenient for bubbling to proxy components, but is used for all callbacks.
        #
        def byte_array_to_bit_array(byte_array)
          byte_array.map do |byte|
            byte.to_i.to_s(2).rjust(8, "0").split("")
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
          read
        end

        def digital_listen(pin)
          #
          # Start the remote listener
          # Need to implement this on Arduino.
          #
        end

        #
        # Mimic Board#update, but in a callback fired through Callbacks#update.
        # This doesn't interfere with using the register directly,
        # and doesn't fire if the board isn't acting as a proxy (no components).
        #
        def enable_proxy
          self.add_callback(:board_proxy) do |bit_array|
            bit_array.each_with_index do |value, pin|
              @components.each do |part|
                part.update(value) if pin.to_i == part.pin
              end
            end
          end
        end
      end
    end
  end
end
