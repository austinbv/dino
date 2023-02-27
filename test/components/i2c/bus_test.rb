require 'test_helper'

class I2CBusTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part  ||= Dino::Components::I2C::Bus.new(board: board, pin:5)
  end
  
  def slave
    @slave ||= Dino::Components::I2C::Slave.new(bus: part, address: 0x30)
  end
  
  def inject_read(lines, wait_for_callbacks = true)
    Thread.new do
      if wait_for_callbacks
        sleep while board.components.empty?
        sleep while board.components.first.callbacks.empty?
      end

      [lines].flatten.each do |line|
        board.update(line)
      end
    end
  end

  def test_initialize
    inject_read("5:")
    assert_equal part.found_devices, []
    refute_nil part.callbacks[:bus_master]
  end
  
  def test_search
    inject_read("5:48:50")
    
    mock = MiniTest::Mock.new.expect :call, nil
    board.stub(:i2c_search, mock) do
      part
    end
    
    mock.verify
    assert_equal part.found_devices, [0x30, 0x32]
  end
  
  def test_write
    inject_read("5:48:50")
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, [0x01, 0x02], some_option: true]
    board.stub(:i2c_write, mock) do
      part.write 0x30, [0x01, 0x02], some_option: true
    end
    mock.verify
  end
  
  def test__read
    inject_read("5:48:50")
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x32, 0x03, 6, some_option: true]
    board.stub(:i2c_read, mock) do
      part._read 0x32, 0x03, 6, some_option: true
    end
    mock.verify
  end
  
  def test_updates_slaves
    inject_read("5:48,50")
    mock = MiniTest::Mock.new.expect :call, nil, [[255, 127]]
    
    slave.stub(:update, mock) do
      part.send(:update, "48-255,127")
      part.send(:update, "50-128,0")
    end
    mock.verify
  end
end
