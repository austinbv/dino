require 'test_helper'

class APIOneWireTest < Minitest::Test
  include Dino::API::Helper
  
  def txrx
    @txrx ||= TxRxMock.new
  end

  def board
    @board ||= Dino::Board.new(txrx)
  end
  
  def test_one_wire_reset
    board
    message = Dino::Message.encode command: 41, pin: 1, value: 255
    
    mock = MiniTest::Mock.new.expect :call, nil, [message]
    txrx.stub(:write, mock) do
      board.one_wire_reset(1, 255)
    end
    mock.verify
  end
  
  def test_one_wire_search
    board
    message = Dino::Message.encode command: 42, pin: 1, aux_message: pack(:uint64, 128, max:8)
    
    mock = MiniTest::Mock.new.expect :call, nil, [message]
    txrx.stub(:write, mock) do
      board.one_wire_search(1, 128)
    end
    mock.verify
  end
  
  def test_one_wire_write
    board
    
    # Calculate length and parasite power properly.
    message1 = Dino::Message.encode command: 43, pin: 1, value: 0b10000000 | 3, aux_message: pack(:uint8, [1,2,3])
    message2 = Dino::Message.encode command: 43, pin: 1, value: 4, aux_message: pack(:uint8, [1,2,3,4])
    
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    txrx.stub(:write, mock) do
      board.one_wire_write(1, true, [1,2,3])
      board.one_wire_write(1, nil, [1,2,3,4])
    end
    mock.verify
    
    # Don't allow more than 127 bytes of data.
    assert_raises(ArgumentError) do 
      too_big = Array.new(128).map { 42 }
      board.one_wire_write(1, true, too_big)
    end
  end
  
  def test_one_wire_read
    board
    message = Dino::Message.encode command: 44, pin: 1, value: 9
        
    mock = MiniTest::Mock.new.expect :call, nil, [message]
    txrx.stub(:write, mock) do
      board.one_wire_read(1, 9)
    end
    mock.verify
  end
end
