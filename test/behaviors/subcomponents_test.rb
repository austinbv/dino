require_relative '../test_helper'

class PinlessComponentMock
  def stop
  end
end

class SinglePinComponentMock
  def pin
    1
  end
end

class MultiPinComponentMock
  def pin
    {a: 1, b: 2}
  end
end 

class SubcomponentsTest < Minitest::Test
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end

  def test_add_remove_pinless
    pinless = PinlessComponentMock.new

    board.add_component(pinless)
    assert_equal [pinless], board.components
    assert_empty board.single_pin_components

    board.remove_component(pinless)
    assert_empty board.components
  end

  def test_add_remove_single_pin
    single_pin = SinglePinComponentMock.new

    board.add_component(single_pin)
    test_hash = {1 => single_pin}
    assert_equal [single_pin], board.components
    assert_equal test_hash,    board.single_pin_components

    board.remove_component(single_pin)
    assert_empty board.components
    refute board.single_pin_components[1]
  end

  def test_add_remove_multi_pin
    multi_pin = MultiPinComponentMock.new

    board.add_component(multi_pin)
    assert_equal [multi_pin], board.components
    assert_empty board.single_pin_components

    board.remove_component(multi_pin)
    assert_empty board.components
  end
  
  def test_calls_stop_on_remove
    pinless = PinlessComponentMock.new
    board.add_component(pinless)

    mock = MiniTest::Mock.new.expect(:call, nil)
    pinless.stub(:stop, mock) do
      board.remove_component(pinless)
    end

    mock.verify
  end
end
