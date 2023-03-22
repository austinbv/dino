require 'test_helper'

class PWMOutTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Basic::PWMOut.new(board: board, pin: 14)
  end
  
  def test_pwm_write
    enable_mock = MiniTest::Mock.new.expect :call, nil
    write_mock = MiniTest::Mock.new
    write_mock.expect :call, nil, [14, 128]
  
    board.stub(:pwm_write, write_mock) do
      part.stub(:pwm_enable, enable_mock) do
        assert_equal :output, part.mode
        part.pwm_write(128)
        assert_equal 128, part.state
      end
    end
    
    part.pwm_write(64)
    assert_equal 64, part.state
    assert_equal :output_pwm, part.mode

    write_mock.verify
    enable_mock.verify
  end

  def test_write_uses_digital_write_at_limits
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [board.high]
    mock.expect :call, nil, [board.low]
    part.stub(:digital_write, mock) do
      part.write(board.pwm_high)
      part.write(board.low)
    end
    mock.verify
  end

  def test_write_uses_analog_write_between_limits
    mock = MiniTest::Mock.new.expect :call, nil, [128]
    part.stub(:pwm_write, mock) do
      part.write(128)
    end
    mock.verify
  end
  
  def test_pwm_enable
    part
    mock = Minitest::Mock.new.expect :call, nil, [14, :output_pwm]
    board.stub(:set_pin_mode, mock) do
      part.pwm_enable
    end
    mock.verify
    assert_equal :output_pwm, part.mode
  end
    
  def test_pwm_disable
    part.pwm_enable
    mock = Minitest::Mock.new
    mock.expect :call, nil, [14, :output]
    board.stub(:set_pin_mode, mock) do
      part.pwm_disable
    end
    mock.verify
    assert_equal :output, part.mode
  end
end
