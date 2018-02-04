module Dino
  module Components
    module OneWire
      class Bus < Basic::DigitalOutput
        include Mixins::Bus
        include Mixins::Reader

        attr_reader :parasite_power, :mutex

        def after_initialize(options = {})
          super(options) if defined?(super)
          @mutex = Mutex.new
          read_power_supply
        end

        def read_power_supply
          sleep 0.1
          reset
          write(SKIP_ROM, READ_POWER_SUPPLY)
          byte = read(1)
          @parasite_power = (byte.to_i[0] == 0) ? true : false
        end

        def reset
          board.write Dino::Message.encode(command: 41, pin: pin)
        end

        def _read(num_bytes)
          board.write Dino::Message.encode(command: 44, pin: pin, value: num_bytes)
        end

        def write(*bytes)
          bytes = bytes.flatten
          raise ArgumentError, "wrong number of arguments (given 0, expected at least 1)" if bytes.empty?

          length = bytes.length
          raise Exception.new('max 127 bytes for single OneWire write') if length > 127

          # Set flag if last byte is a command requiring parasite power after it.
          if parasite_power && [CONVERT_T, COPY_SCRATCH].include?(bytes.last)
            length = length | 0b10000000
          end

          bytes = bytes.pack('C*')
          board.write Dino::Message.encode(command: 43, pin: pin, value: length, aux_message: bytes)
        end
      end
    end
  end
end
