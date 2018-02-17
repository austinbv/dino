module Dino
  module Components
    module OneWire
      class Bus
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
            read_using -> { _search(branch_mask) } do |result|
              device, high_discrepancy = parse_search_result(result)
              @found_devices << device
            end

            # No unsearched discrepancies left.
            break if high_discrepancy == -1

            # Force highest new discrepancy to be a 1 on the next search.
            # i.e. Go as deep as possible into each branch found then back out.
            #
            branch_mask = branch_mask | (2 ** high_discrepancy)

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

          # Gives 0 at every discrepancy we didn't write 1 for on this search.
          new_discrepancies = address ^ complement

          high_discrepancy = -1
          (0..63).each { |i| high_discrepancy = i if new_discrepancies[i] == 0 }

          # LSByte of address is product family.
          klass = family_lookup(address & 0x00000000000000FF)

          [{class: klass, address: address}, high_discrepancy]
        end

        # Result is 16 bytes, 8 byte address and complement interleaved LSByte first.
        def split_search_result(data)
          address = 0
          complement = 0

          data.reverse.each_slice(2) do |comp_byte, addr_byte|
            address = (address << 8) | addr_byte
            complement = (complement << 8) | comp_byte
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
