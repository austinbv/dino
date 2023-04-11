module Dino
  module OneWire
    class Peripheral
      include Behaviors::BusPeripheral
      include Behaviors::BusAddressable
      include Behaviors::Poller
      include Constants

      attr_reader :address
      alias  :bus :board

      def read_scratch(num_bytes, &block)
        atomically do
          bus.add_callback(:read, &block) if block_given?
          match
          bus.write(READ_SCRATCH)
          bus.read(num_bytes)
        end
      end

      def write_scratch(*bytes)
        atomically do
          match
          bus.write(WRITE_SCRATCH)
          bus.write(*bytes)
        end
      end

      def copy_scratch
        atomically do
          match
          bus.write(COPY_SCRATCH)
          sleep 0.05
          bus.reset if bus.parasite_power
        end
      end

      def match
        bus.reset
        if bus.found_devices.count < 2
          bus.write(SKIP_ROM)
        else
          bus.write(MATCH_ROM)
          bus.write(address_bytes)
        end
      end

      def address_bytes
        Helper.address_to_bytes(self.address)
      end

      def serial_number
        @serial_number ||= extract_serial
      end

      def extract_serial
        # Remove CRC & family code.
        serial = (@address & 0x00FFFFFFFFFFFFFF) >> 8
        serial.to_s(16).rjust(12, "0")
      end
    end
  end
end
