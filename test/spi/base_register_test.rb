require_relative '../test_helper'

class BaseRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Dino::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus, pin: 9, bytes: 2, spi_frequency: 800000, spi_mode: 2, spi_bit_order: :lsbfirst }
  end

  def part
    @part ||= Dino::SPI::BaseRegister.new(options)
  end

  def test_defaults
    new_part = Dino::SPI::BaseRegister.new bus: bus, pin: 9
    assert_equal 1,                     new_part.bytes
    assert_equal Array.new(8) {|i| 0},  new_part.state
  end
  
  def test_options
    assert_equal 800000,      part.spi_frequency
    assert_equal 2,           part.spi_mode
    assert_equal :lsbfirst,   part.spi_bit_order
    assert_equal 2,           part.bytes
    new_part = Dino::SPI::BaseRegister.new(options.merge(bytes: 3, pin: 10))
    assert_equal new_part.state, Array.new(24) {|i| 0}
  end
end
