require_relative '../test_helper'

class AddressedBus
  include Dino::Behaviors::Component
  include Dino::Behaviors::BusControllerAddressed
end

class AddressedPeripheral
  include Dino::Behaviors::Component
  include Dino::Behaviors::BusPeripheralAddressed
end

class BusControllerAddressedTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= AddressedBus.new(board: board)
  end
  
  def test_has_mutex
    assert_equal part.mutex.class, Mutex
  end
  
  def test_components
    peripheral = AddressedPeripheral.new(bus: part, address: 1)
    assert_equal part.components, [peripheral]
    
    part.remove_component peripheral
    assert_equal part.components, []
  end

  def test_prevents_duplicate_addresses
    AddressedPeripheral.new(bus: part, address: 1)
    assert_raises do
      AddressedPeripheral.new(bus: part, address: 1)
    end
  end
end
