require 'test_helper'

class I2SlaveTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    unless @bus      
      inject_read("5:48")
      @bus  ||= Dino::Components::I2C::Bus.new(board: board, pin:5)
    else
      @bus
    end
  end
  
  def part
    @part ||= Dino::Components::I2C::Slave.new(bus: bus, address: 0x30)
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
  
  def test_write_and_repeated_start
    part.repeated_start = true
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, [1,2]], repeated_start: true
    bus.stub(:write, mock) do
      part.write [1,2]
    end
  end
  
  def test__read_and_repeated_start
    part.repeated_start = true
    
    inject_read("5:48-127,127,127,127,127,127")
    
    mock = MiniTest::Mock.new.expect :call, nil, [0x30, 0x03, 6], repeated_start: true
    bus.stub(:write, mock) do
      part._read(0, 6)
    end
  end
end
