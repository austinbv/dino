require_relative '../test_helper'

class BusControllerComponent
  include Dino::Behaviors::Component
  include Dino::Behaviors::BusController
end

class BusPeripheralComponent
  include Dino::Behaviors::Component
  include Dino::Behaviors::BusPeripheral
end

class BusPeripheralTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= BusControllerComponent.new(board: board)
  end
  
  def part
    @part ||= BusPeripheralComponent.new(bus: bus, address: 0x22)
  end
  
  def test_initialize
    assert_equal part.board, bus
    assert_equal part.address, 0x22
  end
  
  def test_requires_address
    assert_raises(ArgumentError) { BusPeripheralComponent.new(bus: bus) }
  end
  
  def test_can_use_bus_atomically   
    mock = MiniTest::Mock.new
    1.times {mock.expect(:call, nil)}
    
    bus.mutex.stub(:synchronize, mock) do
      part.atomically { true; false; }
    end
    mock.verify
  end
end
