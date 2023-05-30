require_relative '../test_helper'

class MultiPinComponent
  include Dino::Behaviors::MultiPin
  
  def initialize_pins(options={})
    require_pin :one
    proxy_pin   :two,   Dino::DigitalIO::Output
    proxy_pin   :maybe, Dino::DigitalIO::Input, optional: true
  end
end

class MultiPinTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= MultiPinComponent.new board: board,
                                    pins: { one: 9, two: 10, maybe: 11 }
  end

  def test_validate_pins
    assert_raises(ArgumentError) do
      MultiPinComponent.new board: board, pins: { one: 9, maybe: 11 }
    end
    assert_raises(ArgumentError) do
      MultiPinComponent.new board: board, pins: { two: 10, maybe: 11 }
    end
    MultiPinComponent.new board: board, pins: { one: 9, two:10 }
  end
  
  def test_has_nil_pin
    assert_nil part.pin
  end

  def test_build_proxies
    assert_equal Dino::DigitalIO::Output, part.proxies[:two].class
    assert_equal Dino::DigitalIO::Input, part.proxies[:maybe].class
  end
  
  def attr_reader_exists_for_optional_pins
    part = MultiPinComponent.new board: board, pins: { one: 9, two:10 }
    assert_nil part.maybe
  end

  def test_proxy_reader_methods
    assert_equal part.proxies[:two], part.two
    assert_equal part.proxies[:maybe], part.maybe
  end

  def test_pins_mapped_correctly
    assert_equal 10, part.two.pin
    assert_equal 11, part.maybe.pin
  end

  def test_proxy_states
    part.two.high
    assert_equal({two: board.high, maybe: nil}, part.proxy_states)

    part2 = MultiPinComponent.new board: board, pins: { one: 'A1', two:12 }
    part2.two.low
    assert_equal({two: board.low}, part2.proxy_states)
  end

  def test_required_but_not_proxied_pin_conversion
    part = MultiPinComponent.new board: board, pins: { one: 'A0', two:10 }
    assert_equal 14, part.pins[:one]
  end
end
