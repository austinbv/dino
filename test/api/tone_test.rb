require 'test_helper'

class APIToneTest < Minitest::Test
  include Dino::API::Helper
  
  def txrx
    @txrx ||= TxRxMock.new
  end

  def board
    @board ||= Dino::Board.new(txrx)
  end

  def test_tone
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Message.encode(command: 17, pin: 10, value: 150, aux_message: 2000)]

    board.stub(:write, mock) do
      board.tone(10, 150, 2000)
    end
    mock.verify
  end

  def test_no_tone
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Message.encode(command: 18, pin: 10)]

    board.stub(:write, mock) do
      board.no_tone(10)
    end
    mock.verify
  end
end
