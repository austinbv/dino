require 'test_helper'

class PiezoTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Piezo.new(board: board, pin:8)
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
  end
  
  def test_no_tone
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [part.pin]
    board.stub(:tone, mock) do
      part.no_tone
    end
  end
end
