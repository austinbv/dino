require_relative '../test_helper'

class BoardTest < Minitest::Test
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end

  def test_require_a_connection_object
    assert_raises(Exception) { Dino::Board.new }
  end

  def test_starts_observing_connection
    io = ConnectionMock.new
    mock = MiniTest::Mock.new.expect(:call, nil, [Dino::Board::Default])
    io.stub(:add_observer, mock) do
      Dino::Board.new(io)
    end
    mock.verify
  end

  def test_calls_handshake_on_connection
    mock = MiniTest::Mock.new.expect(:call, "528,1024,14,20")
    connection.stub(:handshake, mock) do
      Dino::Board.new(connection)
    end
    mock.verify
  end

  def test_set_aux_limit
    assert_equal 527, board.aux_limit
  end

  def test_set_eeprom_length
    assert_equal 1024, board.eeprom_length
  end

  def test_set_dac_and_analog_zero
    assert_equal 20, board.dac_zero
    assert_equal 14, board.analog_zero
  end
  
  def test_set_low_high
    assert_equal 0, board.low
    assert_equal 1, board.high
  end
  
  def test_analog_resolution
    assert_equal 255, board.analog_write_high
    assert_equal 8,   board.analog_write_resolution
    assert_equal 1023, board.analog_read_high
    assert_equal 10,   board.analog_read_resolution
    
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Board::API::Message.encode(command:96, value:12)])
    mock.expect(:call, nil, [Dino::Board::API::Message.encode(command:97, value:12)])
    board.stub(:write, mock) do
      board.analog_write_resolution = 12
      board.analog_read_resolution = 12
    end
    mock.verify
    
    assert_equal 0,    board.low
    assert_equal 12,   board.analog_write_resolution
    assert_equal 4095, board.analog_write_high
    assert_equal 12,   board.analog_read_resolution
    assert_equal 4095, board.analog_read_high
  end
  
  def test_eeprom
    mock = MiniTest::Mock.new.expect(:call, "test eeprom", [], board: board)
    Dino::EEPROM::BuiltIn.stub(:new, mock) do
      board.eeprom
    end
    mock.verify
  end

  def test_add_remove_component
    mock = MiniTest::Mock.new
    mock.expect(:methods, [:stop])
    mock.expect(:stop, true)

    board.add_component(mock)
    assert_equal [mock], board.components

    board.remove_component(mock)
    assert_equal [], board.components
  end

  def test_write
    board
    mock = MiniTest::Mock.new.expect(:call, nil, ["message"])
    connection.stub(:write, mock) do
      board.write("message")
    end
    mock.verify
  end

  def test_update_passes_messages_to_correct_components
    mock1 = MiniTest::Mock.new.expect(:update, nil, ["data"])
    4.times { mock1.expect(:pin, 1) }
    
    # Make sure lines are split only on the first colon.
    # Tests for string based pine names too.
    mock2 = MiniTest::Mock.new.expect(:update, nil, ["with:colon"])
    4.times { mock2.expect(:pin, 'A0') }
    
    # Special EEPROM mock.
    mock3 = MiniTest::Mock.new.expect(:update, nil, ["bytes"])
    4.times { mock3.expect(:pin, 'EE') }
     
    board.add_component(mock1)
    board.add_component(mock2)
    board.add_component(mock3)
    board.update("1:data")
    board.update("14:with:colon")
    board.update("3:ignore")
    board.update("EE:bytes")
    mock1.verify
    mock2.verify
    mock3.verify
  end

  def test_convert_pin
    assert_equal 9,  board.convert_pin(9)
    assert_equal 13, board.convert_pin('13')
    assert_equal 15, board.convert_pin('A1')
    assert_equal 15, board.convert_pin(:A1)
    assert_equal 21, board.convert_pin('DAC1')
  end

  def test_incorrect_pin_formats
    assert_raises(ArgumentError) { board.convert_pin('ADC1') }
    board.instance_variable_set(:@dac_zero, nil)
    assert_raises(ArgumentError) { board.convert_pin('DAC1') }
  end
end
