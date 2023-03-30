require_relative '../test_helper'

class I2CPeripheralTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    return @bus if @bus
    inject_read(board, "5:48")
    @bus = Dino::I2C::Bus.new(board: board, pin:5)
  end
  
  def part
    @part ||= Dino::I2C::Peripheral.new(bus: bus, address: 0x30)
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
  
  def test_write_and_repeated_start
    part.repeated_start = true
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, [1,2]], repeated_start: true
    bus.stub(:write, mock) do
      part.write [1,2]
    end
  end
  
  def test__read_and_repeated_start
    part.repeated_start = true
    
    inject_read(board, "5:48-127,127,127,127,127,127")
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, 0x03, 6], repeated_start: true
    bus.stub(:read, mock) do
      part._read(0x03, 6)
    end
  end
end
