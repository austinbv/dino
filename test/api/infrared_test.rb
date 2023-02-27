require 'test_helper'

class APIInfraredTest < Minitest::Test
  include Dino::API::Helper
  
  def txrx
    @txrx ||= TxRxMock.new
  end

  def board
    @board ||= Dino::Board.new(txrx)
  end
  
  def test_infrared_emit
    board
    aux = pack(:uint8, 4) + pack(:uint16, [255,0,255,0])
    message = Dino::Message.encode command: 16, pin: 8, value: 38, aux_message: aux
    
    mock = MiniTest::Mock.new.expect :call, nil, [message]
    txrx.stub(:write, mock) do
      board.infrared_emit 8, 38, [255,0,255,0]
    end
    mock.verify
  end
  
  def test_minimum_pulses
    assert_raises(ArgumentError) do
      board.infrared_emit 8, 38, []
    end
  end
  
  def test_maximum_pulses
    assert_raises(ArgumentError) do 
      board.infrared_emit 8, 38, Array.new(513) { 128 }
    end
  end
end
