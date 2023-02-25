require 'test_helper'

class BusMasterComponent
  include Dino::Components::Setup::Base
  include Dino::Components::Mixins::BusMaster
end

class BusSlaveComponent
  include Dino::Components::Setup::Base
  include Dino::Components::Mixins::BusSlave
end

class BusSlaveTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= BusMasterComponent.new(board: board)
  end
  
  def part
    @part ||= BusSlaveComponent.new(bus: bus, address: 0x22)
  end
  
  def test_initialize
    assert_equal part.board, bus
    assert_equal part.address, 0x22
  end
  
  def test_requires_address
    assert_raises(ArgumentError) { BusSlaveComponent.new(bus: bus) }
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
