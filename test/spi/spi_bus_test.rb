require_relative '../test_helper'

class SPIBusTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @bus ||= Dino::SPI::Bus.new(board: board)
  end

  def pin
    9
  end

  def options
   { mode: 2, frequency: 800000, read: 2, bit_order: :lsbfirst }
  end

  def test_transfer
    mock = MiniTest::Mock.new.expect :call, nil, [pin, options]
    board.stub(:spi_transfer, mock) do
      part.transfer(pin, options)
    end
    mock.verify
  end
  
  def test_listen
    mock = MiniTest::Mock.new.expect :call, nil, [pin, options]
    board.stub(:spi_listen, mock) do
      part.listen(pin, options)
    end
    mock.verify
  end
  
  def test_stop
    mock = MiniTest::Mock.new.expect :call, nil, [pin]
    board.stub(:spi_stop, mock) do
      part.stop(pin)
    end
    mock.verify
  end

  def test_add_and_remove_component
    obj = Object.new
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
end
