require_relative '../../test_helper'

class APIToneTest < Minitest::Test
  include TestPacker
  
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end

  def test_tone
    mock = MiniTest::Mock.new
    aux1 = pack(:uint16, 150) + pack(:uint16, 2000)
    aux2 = pack(:uint16, 300)
    
    mock.expect :call, nil, [Dino::Message.encode(command: 17, pin: 10, value: 1, aux_message: aux1)]
    mock.expect :call, nil, [Dino::Message.encode(command: 17, pin: 10, value: 0, aux_message: aux2)]

    board.stub(:write, mock) do
      board.tone(10, 150, 2000)
      board.tone(10, 300)
    end
    mock.verify
  end
  
  def test_tone_prevents_low_frequencies
    assert_raises(ArgumentError, /freq/i) { board.tone(4, 30, 3000) }
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
