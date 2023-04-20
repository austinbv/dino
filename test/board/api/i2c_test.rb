require_relative '../../test_helper'

class APII2CTest < Minitest::Test
  include Dino::Board::API::Helper
  
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end
  
  def test_search
    board
    message = Dino::Board::API::Message.encode command: 33
    
    mock = MiniTest::Mock.new.expect :call, nil, [message]
    connection.stub(:write, mock) do
      board.i2c_search
    end
    mock.verify
  end

  def test_write
    board
    aux = pack(:uint8, [0x30, 0]) + pack(:uint16, 4) + pack(:uint8, [1,2,3,4])
    # Normal
    message1 = Dino::Board::API::Message.encode command: 34, value: 0b01, aux_message: aux
    # Repeated start
    message2 = Dino::Board::API::Message.encode command: 34, value: 0b00, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    
    connection.stub(:write, mock) do
      board.i2c_write(0x30, [1,2,3,4])
      board.i2c_write(0x30, [1,2,3,4], repeated_start: true)
    end
    mock.verify
  end

  def test_write_limits
    assert_raises { board.i2c_write(0x30, []) }
    assert_raises { board.i2c_write(0x30, Array.new(261) {0x00}) }
  end
  
  def test_read
    board
    aux = pack(:uint8, [0x30, 0]) + pack(:uint16, 4) + pack(:uint8, 0x03)
    # Normal
    message1 = Dino::Board::API::Message.encode command: 35, value: 0b11, aux_message: aux
    # Repeated start
    message2 = Dino::Board::API::Message.encode command: 35, value: 0b10, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    
    connection.stub(:write, mock) do
      board.i2c_read(0x30, 0x03, 4)
      board.i2c_read(0x30, 0x03, 4, repeated_start: true)
    end
    mock.verify
  end
  
  def test_read_without_register
    board
    aux = pack(:uint8, [0x30, 0]) + pack(:uint16, 4) + pack(:uint8, 0x00)
    message = Dino::Board::API::Message.encode command: 35, value: 0b01, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message]
    
    connection.stub(:write, mock) do
      board.i2c_read(0x30, nil, 4)
    end
    mock.verify
  end
  
  def test_write_limits
    assert_raises { board.i2c_read(0x30, nil, 0)   }
    assert_raises { board.i2c_read(0x30, nil, 261) }
  end
end
