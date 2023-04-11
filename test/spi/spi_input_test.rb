require_relative '../test_helper'

class SPIInputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Dino::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus, pin: 9, frequency: 800000, spi_mode: 2, bit_order: :lsbfirst, bytes: 2 }
  end

  def part
    @part ||= Dino::Register::SPIInput.new(options)
  end

  def test_defaults
    part = Dino::Register::SPIInput.new bus: bus, pin: 9
    assert_equal part.bytes, 1
  end
  
  def test_options
    assert_equal part.frequency, 800000
    assert_equal part.spi_mode, 2
    assert_equal part.bit_order, :lsbfirst
    assert_equal part.bytes, 2
  end

  def test_read
    mock = MiniTest::Mock.new.expect :call, nil, [9], mode: 2, frequency: 800000, read: 2, bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      part.read
    end
    mock.verify
  end
  
  def test_listen
    mock = MiniTest::Mock.new.expect :call, nil, [9], mode: 2, frequency: 800000, read: 2, bit_order: :lsbfirst
    bus.stub(:listen, mock) do
      part.listen
    end
    mock.verify
  end
  
  def test_stop
    mock = MiniTest::Mock.new.expect :call, nil, [9]
    bus.stub(:stop, mock) do
      part.stop
    end
    mock.verify
  end
end
