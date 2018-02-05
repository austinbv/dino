require 'spec_helper'

module Dino
  module Components
    module OneWire
      #
      # State machine simulating a bus during address search. Initialize with n for
      # n devices with random (CRC-invalid) addresses. Call #reset before each search.
      #
      class BusSimulator
        def initialize(device_count)
          @devices = []
          device_count.times do
            @devices << { rom: rand(2**64), in_search: true }
          end
          @devices = @devices.uniq
          @index = -1
        end

        def addresses
          @addresses ||= @devices.map { |d| d[:rom] }
        end

        def reset
          @devices.each { |d| d[:in_search] = true }
          @index = -1
        end

        def read_address_bit
          bit = 1
          @index = @index + 1
          @devices.each do |d|
            if d[:in_search]
              bit = bit & d[:rom][@index]
            end
          end
          bit
        end

        def read_complement_bit
          bit = 1
          @devices.each do |d|
            if d[:in_search]
              comp = d[:rom][@index] ^ 1
              bit = bit & comp
            end
          end
          bit
        end

        def write_bit(bit)
          @devices.each do |d|
            d[:in_search] = false unless d[:rom][@index] == bit
          end
        end
      end

      #
      # Class wrapper for Ruby version of the C++ serach function running on the board.
      # Hopefully that doesn't change...
      #
      class BoardSimulator
        def initialize(simulator)
          @simulator = simulator
        end

        def reset
          @simulator.reset
        end

        def search(branch_mask)
          output_string = ""
          (0..7).each do |i|
            addr = 0
            comp = 0
            (0..7).each do |j|
              # Read bit and complement from simulator.
              addr_bit = @simulator.read_address_bit
              comp_bit = @simulator.read_complement_bit

              # Set them in variable.
              addr = addr | (addr_bit * (2 ** j))
              comp = comp | (comp_bit * (2 ** j))

              # Override address bit to a 1 in variable if 1 in mask.
              # Write whatever addr_bit ends up being back to the simulator.
              if branch_mask[(i*8) + j] == 1
                @simulator.write_bit(1)
                addr = addr | (1 * (2 ** j))
              else
                @simulator.write_bit(addr_bit)
              end
            end

            output_string << addr.to_s << "-" << comp.to_s
            output_string << "," if (i != 7 ) # No \n. TxRx strips it IRL.
          end
          output_string
        end
      end

      #
      # Monkeypatch Bus to search the board sim instead of a real board.
      #
      class Bus
        def initialize(options={})
          @board_sim = BoardSimulator.new(options[:simulator])
          super(options)
        end

        def _search(branch_mask)
          @board_sim.reset
          result = @board_sim.search(branch_mask)
          # Manually call #update to simulate callback thread.
          self.update(result)
        end
      end

      describe Bus do
        include BoardMock
        describe '#search' do
          it 'should find all the addresses' do
            # Ignore CRC since the simulator uses random addresses.
            allow(OneWire::Helper).to receive(:crc_check).and_return true
            allow_any_instance_of(Bus).to receive(:read_power_supply).and_return false

            # This gets slow really fast... 256 seems fine.
            sim = BusSimulator.new(256)
            bus = Bus.new(board: board, pin: 7, simulator: sim)

            found_addresses = bus.found_devices.map { |d| d[:address] }
            expect(found_addresses.sort).to eq(sim.addresses.sort)
          end
        end
      end
    end
  end
end
