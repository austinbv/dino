require_relative '../test_helper'

class DS3231Test < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    return @bus if @bus
    board.inject_read("5:104")
    @bus = Dino::I2C::Bus.new(board: board, pin:5)
    @bus.search
    @bus
  end
  
  def part
    @part ||= Dino::RTC::DS3231.new(bus: bus, address: 0x68)
  end
  
  def test_time_to_bcd
    time = Time.new(2000, 1, 1, 0, 0, 0.0)
    bytes = part.time_to_bcd(time)
    assert_equal bytes, [0, 0, 0, 6, 1, 1, 48]
  end
  
  def test_bcd_to_time
    bytes = [0, 0, 0, 6, 1, 1, 48]
    time = part.bcd_to_time(bytes)
    assert_equal time, Time.new(2000, 1, 1, 0, 0, 0.0)
  end
  
  def test_time=
    mock = MiniTest::Mock.new.expect :call, nil, [[0, [0, 0, 0, 6, 1, 1, 48]]]
    part.stub(:write, mock) do
      part.time = Time.new(2000, 1, 1, 0, 0, 0.0)
    end
  end
  
  def test_read
    # Pre-initialize the bus.
    bus
    board.inject_read("5:104-0,0,0,6,1,1,48")
    
    mock = MiniTest::Mock.new.expect :call, nil, [part.address, 0x00, 7], repeated_start: false
    bus.stub(:_read, mock) do
      part.time
    end
  end
  
  def test_pre_callback_filter
    mock = MiniTest::Mock.new.expect :call, nil, [Time.new(2000, 1, 1, 0, 0, 0.0)]
    part.stub(:update_state, mock) do
      bus.send(:update, "104-0,0,0,6,1,1,48")
    end
  end
end
