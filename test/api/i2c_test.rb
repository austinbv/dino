require 'test_helper'

class APII2CTest < Minitest::Test
  include Dino::API::Helper
  
  def txrx
    @txrx ||= TxRxMock.new
  end

  def board
    @board ||= Dino::Board.new(txrx)
  end
  
  def test_search
    board
    message = Dino::Message.encode command: 33
    
    mock = MiniTest::Mock.new.expect :call, nil, [message]
    txrx.stub(:write, mock) do
      board.i2c_search
    end
    mock.verify
  end

  def test_write
    board
    aux = pack :uint8, [0x30, 0, 4, [1,2,3,4]]
    # Normal
    message1 = Dino::Message.encode command: 34, value: 0b01, aux_message: aux
    # Repeated start
    message2 = Dino::Message.encode command: 34, value: 0b00, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    
    txrx.stub(:write, mock) do
      board.i2c_write(0x30, [1,2,3,4])
      board.i2c_write(0x30, [1,2,3,4], repeated_start: true)
    end
    mock.verify
  end
  
  def test_read
    board
    aux = pack :uint8, [0x30, 0, 0x03, 4]
    # Normal
    message1 = Dino::Message.encode command: 35, value: 0b11, aux_message: aux
    # Repeated start
    message2 = Dino::Message.encode command: 35, value: 0b10, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    
    txrx.stub(:write, mock) do
      board.i2c_read(0x30, 0x03, 4)
      board.i2c_read(0x30, 0x03, 4, repeated_start: true)
    end
    mock.verify
  end
  
  def test_read_without_register
    board
    aux = pack :uint8, [0x30, 0, 0, 4]
    message = Dino::Message.encode command: 35, value: 0b01, aux_message: aux

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message]
    
    txrx.stub(:write, mock) do
      board.i2c_read(0x30, nil, 4)
    end
    mock.verify
  end
end
