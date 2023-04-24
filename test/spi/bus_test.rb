require_relative '../test_helper'

class TempSpiPeripheral
  def initialize(pin)
    @pin = pin
  end
  
  attr_reader :pin
end

class SPIBusTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @bus ||= Dino::SPI::Bus.new(board: board)
  end

  PIN = 9
  OPTIONS = { mode: 2, frequency: 800000, read: 2, bit_order: :lsbfirst }

  def test_transfer
    mock = MiniTest::Mock.new.expect :call, nil, [PIN], **OPTIONS
    board.stub(:spi_transfer, mock) do
      part.transfer(PIN, **OPTIONS)
    end
    mock.verify
  end
  
  def test_listen
    mock = MiniTest::Mock.new.expect :call, nil, [PIN], **OPTIONS
    board.stub(:spi_listen, mock) do
      part.listen(PIN, **OPTIONS)
    end
    mock.verify
  end
  
  def test_stop
    mock = MiniTest::Mock.new.expect :call, nil, [PIN]
    board.stub(:spi_stop, mock) do
      part.stop(PIN)
    end
    mock.verify
  end

  def test_add_and_remove_component
    obj = TempSpiPeripheral.new(1)
    part.add_component(obj)
    assert board.components.include?(obj)

    part.remove_component(obj)
    refute board.components.include?(obj)
  end

  def test_set_pin_mode
    mock = MiniTest::Mock.new.expect :call, nil, [9, :output]
    board.stub(:set_pin_mode, mock) do
      part.set_pin_mode(9, :output)
    end
    mock.verify
  end

  def test_unique_select_pins
    part.add_component TempSpiPeripheral.new(1)

    assert_raises do
      part.add_component TempSpiPeripheral.new(1)
    end
  end
end
