require 'test_helper'

class MultiPinComponent
  include Dino::Components::Setup::MultiPin
  require_pin :one
  proxy_pin   two:   Dino::Components::Basic::DigitalOutput
  proxy_pin   maybe: Dino::Components::Basic::DigitalInput, optional: true
end

class MultiPinSetupTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= MultiPinComponent.new board: board,
                                    pins: { one: 9, two: 10, maybe: 11 }
  end

  def test_require_pins
    assert_equal MultiPinComponent.class_variable_get(:@@required_pins), [:one, :two]
  end

  def test_proxy_pins
    assert_equal MultiPinComponent.class_variable_get(:@@proxied_pins),
                 {two:   Dino::Components::Basic::DigitalOutput,
                  maybe: Dino::Components::Basic::DigitalInput}
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

  def test_build_proxies
    assert_equal Dino::Components::Basic::DigitalOutput, part.proxies[:two].class
    assert_equal Dino::Components::Basic::DigitalInput, part.proxies[:maybe].class
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
  end
end
