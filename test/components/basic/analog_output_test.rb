require 'test_helper'

class AnalogOutputTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Basic::AnalogOutput.new(board: board, pin: 14)
  end

  def test_analog_write
    mock = MiniTest::Mock.new.expect :call, nil, [14, 128]
    board.stub(:analog_write, mock) do
      part.analog_write(128)
    end
    mock.verify
    assert_equal part.state, 128
  end

  def test_write_uses_digital_write_at_limits
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [board.high]
    mock.expect :call, nil, [board.low]
    part.stub(:digital_write, mock) do
      part.write(board.analog_high)
      part.write(board.low)
    end
    mock.verify
  end

  def test_write_uses_analog_write_between_limits
    mock = MiniTest::Mock.new.expect :call, nil, [128]
    part.stub(:analog_write, mock) do
      part.write(128)
    end
    mock.verify
  end
end
