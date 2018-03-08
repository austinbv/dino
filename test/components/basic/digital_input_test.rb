require 'dino'
require 'board_mock'
require 'minitest/autorun'

class DigitalInputTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Basic::DigitalInput.new(board: board, pin: 14)
  end

  def test_start_listening_immediately
    mock = MiniTest::Mock.new.expect :call, nil, [14, 4]
    board.stub(:digital_listen, mock) do
      part
    end
    mock.verify
  end

  def test__read
    mock = MiniTest::Mock.new.expect :call, nil, [14]
    board.stub(:digital_read, mock) do
      part._read
    end
    mock.verify
  end

  def test__listen
    part
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [14, 4]
    mock.expect :call, nil, [14, 32]
    board.stub(:digital_listen, mock) do
      part._listen
      part._listen(32)
    end
    mock.verify
  end

  def test_on_low
    low_cb  = MiniTest::Mock.new.expect :call, nil
    high_cb = MiniTest::Mock.new
    part.on_low { low_cb.call }
    part.on_high { high_cb.call }
    part.update(board.low)
    low_cb.verify
    high_cb.verify
  end

  def test_on_high
    low_cb  = MiniTest::Mock.new
    high_cb = MiniTest::Mock.new.expect :call, nil
    part.on_low { low_cb.call }
    part.on_high { high_cb.call }
    part.update(board.high)
    low_cb.verify
    high_cb.verify
  end
end
