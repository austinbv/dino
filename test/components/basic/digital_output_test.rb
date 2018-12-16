require 'dino'
require 'board_mock'
require 'minitest/autorun'

class DigitalOutputTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Basic::DigitalOutput.new(board: board, pin: 14)
  end

  def read_state_on_initialize
    mock = MiniTest::Mock.new.expect :call, nil, [14]
    board.stub(:digital_read, mock) do
      part
    end
    mock.verify
  end

  def test_digital_write
    part
    mock = MiniTest::Mock.new.expect :call, nil, [14, board.high]
    board.stub(:digital_write, mock) do
      part.digital_write(board.high)
    end
    mock.verify
    assert_equal board.high, part.state
  end

  def test_high_and_low
    part
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [board.high]
    mock.expect :call, nil, [board.low]
    part.stub(:digital_write, mock) do
      part.high
      part.low
    end
    mock.verify
  end

  def test_toggle
    part.low
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:high, mock) do
      part.toggle
    end
    mock.verify

    part.high
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:low, mock) do
      part.toggle
    end
    mock.verify
  end
end
