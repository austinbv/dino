require 'dino'
require 'board_mock'
require 'minitest/autorun'

# State machine simulating a bus during address search. Initialize with n for
# n devices with random (CRC-invalid) addresses. Call #reset before each search.
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

# Ruby version of the C++ functions running on the board.
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
        # Write whatever addr_bit ends up being back to the bus simulator.
        if branch_mask[(i*8) + j] == 1
          @simulator.write_bit(1)
          addr = addr | (1 * (2 ** j))
        else
          @simulator.write_bit(addr_bit)
        end
      end

      output_string << addr.to_s << "," << comp.to_s
      output_string << "," if (i != 7 ) # No \n. TxRx strips it IRL.
    end
    output_string
  end
end

# Monkeypatch Bus and Helper to stub in simulations.
module Dino
  module Components
    module OneWire

      class Bus
        def read_power_supply
          @parasite_power = false
        end

        def initialize(options={})
          @board_sim = options[:board_sim]
          super(options)
        end

        def _search(branch_mask)
          @board_sim.reset
          result = @board_sim.search(branch_mask)
          # Manually call #update to simulate data recevieved from board.
          self.update(result)
        end
      end

      class Helper
        def self.crc_check(bytes)
          true
        end
      end
    end
  end
end

class OneWireEnumeratorTest < Minitest::Test
  def test_find_all_addresses
    # This gets slow with large number of devices.
    bus_sim = BusSimulator.new(100)
    board_sim = BoardSimulator.new(bus_sim)
    bus = Dino::Components::OneWire::Bus.new board: BoardMock.new,
                                             pin: 1,
                                             board_sim: board_sim
    bus.search

    found_addresses = bus.found_devices.map { |d| d[:address] }
    assert_equal found_addresses.sort, bus_sim.addresses.sort
  end
end
