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
    aux = pack(:uint8, 0x00) + pack(:uint8, [1,2,3,4])
    address = 0x30
      
    # Normal
    message1 = Dino::Board::API::Message.encode command: 34, pin: 0x30 | (1 << 7), value: 4, aux_message: aux
    # Repeated start
    message2 = Dino::Board::API::Message.encode command: 34, pin: 0x30 | (0 << 7), value: 4, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    
    connection.stub(:write, mock) do
      board.i2c_write(0x30, [1,2,3,4])
      board.i2c_write(0x30, [1,2,3,4], i2c_repeated_start: true)
    end
    mock.verify
  end

  def test_write_limits
    assert_raises { board.i2c_write(0x30, Array.new(33) {0x00}) }
    assert_raises { board.i2c_write(0x30, Array.new(0)  {0x00}) }
  end

  def test_read
    board
    aux = pack(:uint8, 0x00) + pack(:uint8, [1, 0x03])
    # Normal
    message1 = Dino::Board::API::Message.encode command: 35, pin: 0x30 | (1 << 7), value: 4, aux_message: aux
    # Repeated start
    message2 = Dino::Board::API::Message.encode command: 35, pin: 0x30 | (0 << 7), value: 4, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    
    connection.stub(:write, mock) do
      board.i2c_read(0x30, 0x03, 4)
      board.i2c_read(0x30, 0x03, 4, i2c_repeated_start: true)
    end
    mock.verify
  end
  
  def test_read_without_register
    board
    aux = pack(:uint8, 0x00) + pack(:uint8, [0])
    message = Dino::Board::API::Message.encode command: 35, pin: 0x30 | (1 << 7), value: 4, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message]
    
    connection.stub(:write, mock) do
      board.i2c_read(0x30, nil, 4)
    end
    mock.verify
  end

  def test_read_limits
    assert_raises { board.i2c_read(0x30, nil, 33) }
    assert_raises { board.i2c_read(0x30, nil, 0)  }
  end

  def test_frequencies
    board
    data = [1,2,3,4]
    address = 0x30
      
    messages = []
    # 100 kHz, 400 kHz, 1 Mhz, 3.4 MHz
    [0x00, 0x01, 0x02, 0x03].each do |code|
      messages << Dino::Board::API::Message.encode(command: 34, pin: 0x30 | (1 << 7), value: 4, aux_message: pack(:uint8, code) + pack(:uint8, data))
    end

    mock = MiniTest::Mock.new
    messages.each do |message|
      mock.expect :call, nil, [message]
    end
    connection.stub(:write, mock) do
      board.i2c_write(address, data, i2c_frequency: 100000)
      board.i2c_write(address, data, i2c_frequency: 400000)
      board.i2c_write(address, data, i2c_frequency: 1000000)
      board.i2c_write(address, data, i2c_frequency: 3400000)
    end
    mock.verify

    assert_raises(ArgumentError) { board.i2c_write(0x30, [1,2,3,4], i2c_frequency: 5000000) }
  end
end
