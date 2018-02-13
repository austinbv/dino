module Dino
  module Components
    module OneWire
      class Bus
        # 1 bits in mask set discrepancies to 1. 0 leaves bit as read from bus.
        def _search(branch_mask)
          reset
          write(SEARCH_ROM)
          board.one_wire_search(pin, branch_mask)
        end

        def search
          @found_devices = []
          branch_mask = 0
          high_discrepancy = 0

          loop do
            self.add_callback(:read) do |result|
              device, high_discrepancy = parse_search_result(result)
              @found_devices << device
            end

            _search(branch_mask)
            block_until_read

            # No untested discrepancies left. End the search.
            break if high_discrepancy == - 1

            # If high_discrepancy was not forced 1 last iteration, do it next.
            # i.e. Go as deep as possible into each branch found then back out.
            #
            if branch_mask[high_discrepancy] == 0
              branch_mask = branch_mask | (2 ** high_discrepancy)
            end

            # Clear bits above high_discrepancy so we don't repeat branches.
            # When high_discrepancy < MSB of branch_mask, this moves us
            # one node out, closer to the root, and finishing the search.
            #
            unset_mask = 0xFFFFFFFFFFFFFFFF >> (63 - high_discrepancy)
            branch_mask = branch_mask & unset_mask
          end
        end

        def parse_search_result(result)
          address, complement = split_search_result(result)

          raise "CRC error during OneWire search" unless Helper.crc_check(address)

          if (address & complement) > 0
            raise "OneWire device not connected or disconnected during search"
          end

          #
          # XOR address with complement to give a 0 at each discrepancy.
          # XOR again with 64 1s to flip, so each discrepancy is a 1 instead.
          #
          new_discrepancies = (address ^ complement) ^ 0xFFFFFFFFFFFFFFFF

          #
          # Note: Discrepancies forced to 1 in an iteration will not show up as
          # discrepancies when parsing the result from that iteration. The board
          # will have read 0-0 from the bus, but we told it to override the
          # address bit to a 1, so we get back (1-0), as if no discrepancy.
          #
          # This is OK. We only want the highest discrepancy we did not set to 1.
          #
          high_discrepancy = new_discrepancies.bit_length - 1

          # LSByte of address is product family. Check for existing class.
          klass = family_lookup(address & 0x00000000000000FF)

          [{class: klass, address: address}, high_discrepancy]
        end

        # Search result is a comma separated list of 8 byte-pairs. Each pair is
        # formatted "addressByte-compByte". Pairs are ordered LS byte first.
        #
        def split_search_result(str)
          byte_pairs = str.split(",")
          address = 0
          complement = 0

          byte_pairs.reverse.each do |pair|
            address_byte, complement_byte = pair.split("-").map(&:to_i)
            address = (address << 8) | address_byte
            complement = (complement << 8) | complement_byte
          end

          [address, complement]
        end

        # Set FAMILY_CODE in slave class to get it identified during search.
        def family_lookup(family_code)
          OneWire.constants.each do |const|
            obj = OneWire.const_get(const)
            if (obj.is_a? Class) && (obj.const_defined? "FAMILY_CODE")
              return obj if obj::FAMILY_CODE == family_code
            end
          end
          return nil
        end
      end
    end
  end
end
