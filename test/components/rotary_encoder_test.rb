require 'test_helper'

class RotaryEncoderTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::RotaryEncoder.new board: board, pins: {data:3, clock: 4}
  end

  def test_sets_steps_per_revolution
    assert_equal part.degrees_per_step, 12
    part2 = Dino::Components::RotaryEncoder.new board: board, pins: {data:3, clock: 4}, steps_per_revolution: 40
    assert_equal part2.degrees_per_step, 9
  end
  
  def test_resets_on_initialize
    assert_equal part.state, {steps: 0, angle: 0}
  end
  
  def test_calls_listen_on_both_pins_with_given_divider
    clock_mock = MiniTest::Mock.new.expect(:call, nil, [1])
    clock_mock.expect(:call, nil, [2])
    data_mock = MiniTest::Mock.new.expect(:call, nil, [1])
    data_mock.expect(:call, nil, [2])
    
    part.clock.stub(:listen, clock_mock) do
      part.data.stub(:listen, data_mock) do
        part.send(:after_initialize)
        part.send(:after_initialize, divider: 2)
      end
    end
  end
  
  def test_observes_on_initialize
    mock = MiniTest::Mock.new.expect(:call, nil)
    part.stub(:observe_pins, mock) do
      part.send(:after_initialize)
    end
  end
  
  def test_observes_the_right_pin
    refute_empty part.clock.callbacks
    assert_empty part.data.callbacks
        
    part2 = Dino::Components::RotaryEncoder.new board: board, pins: {data:4, clock: 3}
    
    refute_empty part2.data.callbacks
    assert_empty part2.clock.callbacks
  end
  
  def test_goes_the_right_direction
    part.data.send(:update, 1)
    part.clock.send(:update, 1)
    assert_equal part.state, { steps: 1, angle: 12.0}
    
    part.reset
    
    part.data.send(:update, 1)
    part.clock.send(:update, 0)
    assert_equal part.state, { steps: -1, angle: 348.0}
  end
  
  def test_callback_prefilter
    part.data.send(:update, 1)
    part.clock.send(:update, 1)
    callback_value = nil
    part.add_callback do |value|
      callback_value = value
    end
    part.data.send(:update, 1)
    part.clock.send(:update, 1)
    
    assert_equal callback_value, {change: 1, steps: 2, angle: 24.0}
  end
  
  def test_update_state_removes_change
    part.data.send(:update, 1)
    part.clock.send(:update, 1)
    assert_nil part.state[:change]
  end
end
