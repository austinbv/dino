require_relative '../test_helper'

class OutputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { clock: 12, data: 11, latch: 8 } }
  end

  def part
    @part ||= Dino::Register::ShiftOutput.new(options)
  end
  
  def led
    @led ||= Dino::LED.new(board: part, pin: 0)
  end
  
  def test_sets_byte_length
    new_part = Dino::Register::ShiftOutput.new(options.merge(bytes: 2))
    assert_equal 2, new_part.bytes 
  end
  
  def test_state_setup
    new_part = Dino::Register::ShiftOutput.new(options.merge(bytes: 3))
    assert_equal new_part.state, Array.new(24) {|i| 0}
    assert_equal new_part.instance_variable_get(:@write_delay), 0.001
    assert_equal new_part.instance_variable_get(:@buffer_writes), true
  end
  
  def test_write_buffering_control
    new_part = Dino::Register::ShiftOutput.new(options.merge(bytes: 3, buffer_writes: false, write_delay: 0.5))
    assert_equal new_part.instance_variable_get(:@write_delay), 0.5
    assert_equal new_part.instance_variable_get(:@buffer_writes), false
  end
  
  def test_updates_and_writes_state_for_children
    led
    
    mock = MiniTest::Mock.new.expect :call, nil, [[1]]
    part.stub(:write, mock) do
      led.on
      sleep 0.002
    end
    mock.verify
    
    assert_equal part.state, [1,0,0,0,0,0,0,0]
  end
  
  def test_implements_digital_read_for_children
    led
    
    mock = MiniTest::Mock.new.expect :call, nil, [0]
    part.stub(:digital_read, mock) do
      led.board.digital_read(led.pin)
    end
    mock.verify
  end
  
  def test_bit_and_byte_orders_correct
    part.instance_variable_set(:@bytes, 2)
    bit_array = "0101010100001111".split("")
    
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [[0b11110000, 0b10101010]]
    part.stub(:write, mock) do
      part.instance_variable_set(:@state, bit_array)
      part.write_state
      sleep 0.002
    end
    mock.verify
    
    assert_equal part.state, bit_array
  end
  
  def test_disable_buffering
    part.instance_variable_set(:@buffer_writes, false)
    part.instance_variable_set(:@write_delay, 1)
    led.on
    assert_nil part.thread
  end
end
