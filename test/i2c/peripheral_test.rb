require_relative '../test_helper'

class I2CPeripheralTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    return @bus if @bus
    board.inject_read("5:48")
    @bus = Dino::I2C::Bus.new(board: board, pin:5)
    @bus.search
    @bus
  end
  
  def part
    @part ||= Dino::I2C::Peripheral.new(bus: bus, i2c_address: 0x30)
  end
    
  def test_write_and_repeated_start
    part.i2c_repeated_start = true
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, [1,2]], i2c_repeated_start: true, i2c_frequency: nil
    bus.stub(:write, mock) do
      part.write [1,2]
    end
  end

  def test_frequency
    part.i2c_frequency = 400000
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, [1,2]], i2c_repeated_start: nil, i2c_frequency: 400000
    bus.stub(:write, mock) do
      part.write [1,2]
    end
  end
  
  def test__read_and_repeated_start
    part.i2c_repeated_start = true
    
    board.inject_read("5:48-127,127,127,127,127,127")
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, 0x03, 6], i2c_repeated_start: true, i2c_frequency: nil
    bus.stub(:read, mock) do
      part._read(0x03, 6)
    end
  end
end
