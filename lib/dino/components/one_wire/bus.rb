module Dino
  module Components
    module OneWire
      class Bus
        include Setup::SinglePin
        include Mixins::Bus
        include Mixins::Reader

        attr_reader :found_devices, :parasite_power, :mutex

        def after_initialize(options = {})
          super(options)
          @mutex = Mutex.new
          @found_devices = []
          read_power_supply
        end

        # Without driving low first, results are inconsistent.
        # Only the first (LS) bit matters, but it's easier to read a whole byte.
        #
        def read_power_supply
          board.set_pin_mode(self.pin, :out)
          board.digital_write(self.pin, board.low)
          sleep 0.1

          reset
          write(SKIP_ROM, READ_POWER_SUPPLY)
          byte = read(1)

          @parasite_power = (byte.to_i[0] == 0) ? true : false
        end

        def reset
          board.one_wire_reset(pin)
        end

        def device_present
          present = false
          self.add_callback(:read) do |result|
            present = (result.to_i == 0) ? true : false
          end

          board.one_wire_reset(pin, 1)
          block_until_read
          present
        end

        def _read(num_bytes)
          board.one_wire_read(pin, num_bytes)
        end

        def write(*bytes)
          pp = parasite_power && [CONVERT_T, COPY_SCRATCH].include?(bytes.last)
          board.one_wire_write(pin, pp, bytes)
        end
      end
    end
  end
end
