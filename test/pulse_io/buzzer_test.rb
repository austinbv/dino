require_relative '../test_helper'

class BuzzerTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::PulseIO::Buzzer.new(board: board, pin:8)
  end

  def test_low_on_initialize
    assert_equal part.state, board.low
  end
  
  def test_tone
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [part.pin, 60, nil]
    mock.expect :call, nil, [part.pin, 120, 2000]
    board.stub(:tone, mock) do
      part.tone(60)
      part.tone(120, 2000)
    end
    mock.verify
  end
  
  def test_no_tone
    part
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [part.pin]
    board.stub(:no_tone, mock) do
      part.no_tone
    end
    mock.verify
  end
  
  def stop
    mock = MiniTest::Mock.new
    mock.expect :call, nil
    mock.expect :call, nil
    part.stub(:kill_thread, mock) do
      part.stub(:no_tone, mock) do
        part.stop
      end
    end
    mock.verify
  end
end
