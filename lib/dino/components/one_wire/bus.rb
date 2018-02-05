module Dino
  module Components
    module OneWire
      class Bus
        include Setup::SinglePin
        include Mixins::Bus
        include Mixins::Reader

        attr_reader :found_devices, :parasite_power, :mutex

        def after_initialize(options = {})
          super(options) if defined?(super)
          @mutex = Mutex.new
          @found_devices = []
          read_power_supply
          search
        end

        def search
          branch_mask = 0
          high_discrepancy = 0

          loop do
            self.add_callback(:read) do |result|
              #
              # We get a device hash (class and ROM address) as a parsed result,
              # plus the bit index of the highest discrepancy from the last run.
              #
              device, high_discrepancy = Helper.parse_search_result(result)
              @found_devices << device
            end
            _search(branch_mask)
            block_until_read

            #
            # Since we're zero-indexed unlike the datasheet, this is when the
            # search ends. There's no discrepancy left even at the lowest bit.
            #
            break if high_discrepancy == - 1

            #
            # If high_discrepancy was not a forced 1 last time, do it next time.
            # This way we go as deep as possible into each new branch first.
            #
            if branch_mask[high_discrepancy] == 0
              branch_mask = branch_mask | (2 ** high_discrepancy)
            end

            #
            # Clear bits above high_discrepancy so we don't repeat branches.
            # When high_discrepancy < MSB of branch_mask, this moves us
            # one node closer to the root and finishing the search.
            #
            unset_mask = 0xFFFFFFFFFFFFFFFF >> (63 - high_discrepancy)
            branch_mask = branch_mask & unset_mask
          end

          # Just to be safe...
          @found_devices = @found_devices.uniq
        end

        #
        # Reset the bus, then send the search command, along with a 64-bit
        # mask of bits to write 1 for.
        #
        def _search(high_mask)
          reset
          write(SEARCH_ROM)
          board.write Dino::Message.encode command: 42,
                                           pin: pin,
                                           aux_message: [high_mask].pack('<Q')
        end

        #
        # Drive low, then send READ_POWER_SUPPLY instruction, and read 1 byte.
        # Any device using parasite power will pull the lowest bit to 0.
        #
        def read_power_supply
          # Inconsistent readings without this.
          self.mode = :out
          board.digital_write(self.pin, board.low)
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
