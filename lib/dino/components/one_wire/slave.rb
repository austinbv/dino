module Dino
  module Components
    module OneWire
      class Slave
        include Setup::Base
        attr_reader :address
        alias  :bus :board

        #
        # Remove the MSByte (CRC) and LSByte (family code) from slave's ROM
        # address to get a printable 48-bit serial number in hex.
        #
        def serial_number
          address = @address & 0x00FFFFFFFFFFFFFF
          address = address >> 8
          address.to_s(16).rjust(12, "0")
        end

        def initialize(options={})
          options[:board] ||= options[:bus]
          super(options)
        end

        def after_initialize(options={})
          super(options)
          unless options[:address]
            raise ArgumentError, 'missing 1-Wire slave ROM address; try searching first'
          end
          @address = options[:address]
        end

        def read_scratch(num_bytes)
          atomically do
            match
            bus.write(READ_SCRATCH)
            bus.read(num_bytes)
          end
        end

        def write_scratch(bytes)
          atomically do
            match
            bus.write(WRITE_SCRATCH)
            bus.write(bytes)
          end
        end

        def copy_scratch
          atomically do
            match
            bus.write(COPY_SCRATCH)
            sleep 0.02
            bus.reset if bus.parasite_power
          end
        end

        def atomically(&block)
          bus.mutex.synchronize do
            block.call
          end
        end

        def match
          bus.reset
          # Skip ROM match if only one device on the bus.
          if bus.found_devices == 1
            bus.write(SKIP_ROM)
          else
            bus.write(MATCH_ROM)
            bus.write(Helper.address_to_bytes(self.address))
          end
        end
      end
    end
  end
end
