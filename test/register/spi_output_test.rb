require_relative '../test_helper'

class SPIOutputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pin: 9, frequency: 800000, spi_mode: 2, bit_order: :lsbfirst }
  end

  def part
    @part ||= Dino::Register::SPIOutput.new(options)
  end

  def test_defaults
    part = Dino::Register::SPIOutput.new board: board, pin: 9
    assert_equal part.frequency, 1000000
    assert_equal part.spi_mode,  0
    assert_equal part.bit_order, :msbfirst
  end
  
  def test_options
    assert_equal part.frequency, 800000
    assert_equal part.spi_mode, 2
    assert_equal part.bit_order, :lsbfirst
  end

  def test_write
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [9], mode: 2, frequency: 800000, write: [0], bit_order: :lsbfirst
    mock.expect :call, nil, [9], mode: 2, frequency: 800000, write: [255,127], bit_order: :lsbfirst
    board.stub(:spi_transfer, mock) do
      part.write(255,127)
    end
    mock.verify
  end
end
