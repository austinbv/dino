require_relative '../test_helper'

class I2CBusTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part  ||= Dino::I2C::Bus.new(board: board, pin:5)
  end
  
  def peripheral
    @peripheral ||= Dino::I2C::Peripheral.new(bus: part, address: 0x30)
  end
  
  def inject_read(board, line, wait_for_callbacks = true)
    Thread.new do
      if wait_for_callbacks
        sleep(0.01) while board.components.empty?
        sleep(0.01) while !board.components.first.callbacks[:read]
      end
      board.update(line)
    end
  end

  def test_initialize
    inject_read(board, "5:")
    assert_equal part.found_devices, []
    refute_nil part.callbacks[:bus_master]
  end

  def test_search
    inject_read(board, "5:48:50")
    
    mock = MiniTest::Mock.new.expect :call, nil
    board.stub(:i2c_search, mock) do
      part; sleep 0.15
    end
    
    mock.verify
    assert_equal part.found_devices, [0x30, 0x32]
  end

  def test_write
    # Let the search happen first.
    inject_read(board, "5:48:50")
    part; sleep 0.15

    mock = MiniTest::Mock.new.expect :call, nil, [0x30, [0x01, 0x02]], some_option: true
    board.stub(:i2c_write, mock) do
      part.write 0x30, [0x01, 0x02], some_option: true
    end
    mock.verify
  end
  
  def test__read
    # Let the search happen first.
    inject_read(board, "5:48:50")
    part; sleep 0.15

    inject_read(board, "5:48-255,0,255,0,255,0")
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x32, 0x03, 6], some_option: true
    board.stub(:i2c_read, mock) do
      part._read 0x32, 0x03, 6, some_option: true
    end
    mock.verify
  end
  
  def test_updates_peripherals
    # Let the search happen first.
    inject_read(board, "5:48:50")
    part; sleep 0.15

    mock = MiniTest::Mock.new.expect :call, nil, [[255, 127]]
    
    peripheral.stub(:update, mock) do
      part.send(:update, "48-255,127")
      part.send(:update, "50-128,0")
    end
    mock.verify
  end
end
