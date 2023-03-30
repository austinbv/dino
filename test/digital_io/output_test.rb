require_relative '../test_helper'

class DigitalIOOutputTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::DigitalIO::Output.new(board: board, pin: 14)
  end

  def test_read_state_on_initialize
    mock = MiniTest::Mock.new.expect :call, nil, [14]
    board.stub(:digital_read, mock) do
      part
    end
    mock.verify
  end

  def test_digital_write
    part
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [14, board.high]
    mock.expect :call, nil, [14, board.low]
    mock.expect :call, nil, [14, board.low]
    mock.expect :call, nil, [14, board.high]
    board.stub(:digital_write, mock) do
      part.digital_write(board.high)
      part.digital_write(nil)
      part.digital_write("0")
      part.digital_write("1")
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
