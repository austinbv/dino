module Dino
  module Components
    module OneWire
      class Bus
        include Setup::SinglePin
        include Mixins::BusMaster
        include Mixins::Reader

        attr_reader :found_devices, :parasite_power

        def after_initialize(options = {})
          super(options)
          @found_devices = []
          read_power_supply
        end

        def read_power_supply
          mutex.synchronize do
            # Without driving low first, results are inconsistent.
            board.set_pin_mode(self.pin, :out)
            board.digital_write(self.pin, board.low)
            sleep 0.1

            reset
            write(SKIP_ROM, READ_POWER_SUPPLY)

            # Only LSBIT matters, but we can only read whole bytes.
            byte = read(1)
            @parasite_power = (byte[0] == 0) ? true : false
          end
        end

        def pre_callback_filter(bytes)
          bytes = bytes.split(",").map(&:to_i)
          bytes.length > 1 ? bytes : bytes[0]
        end

        def device_present
          mutex.synchronize do
            byte = read_using -> { reset(1) }
            (byte == 0) ? true : false
          end
        end

        def reset(get_presence=0)
          board.one_wire_reset(pin, get_presence)
        end

        def read(num_bytes)
          read_using -> { board.one_wire_read(pin, num_bytes) }
        end

        def write(*bytes)
          pp = parasite_power && [CONVERT_T, COPY_SCRATCH].include?(bytes.last)
          board.one_wire_write(pin, pp, bytes)
        end
      end
    end
  end
end
