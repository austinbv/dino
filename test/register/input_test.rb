require_relative '../test_helper'

class InputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { clock: 12, data: 11, latch: 8 } }
  end

  # Shift in is probably the simplest form of an input register.
  def part
    @part ||= Dino::Register::ShiftInput.new(options)
  end
  
  def button
    @button ||= Dino::DigitalIO::Button.new(board: part, pin: 0)
  end
  
  def test_sets_byte_length
    new_part = Dino::Register::ShiftInput.new(options.merge(bytes: 2))
    assert_equal 2, new_part.bytes 
  end
  
  def test_state_setup
    new_part = Dino::Register::ShiftInput.new(options.merge(bytes: 3))
    assert_equal new_part.state, Array.new(24) {|i| 0}
    assert_equal new_part.instance_variable_get(:@reading_pins), Array.new(24) { false }
    assert_equal new_part.instance_variable_get(:@listening_pins), Array.new(24) { false }
    refute_nil   new_part.callbacks[:board_proxy]
  end
  
  def test_updates_child_components
    button
    part.update("1")
    assert button.high?
    part.update("0")
    assert button.low?
  end
  
  def test_bit_array_conversion_and_state_update
    part.update("127")
    assert_equal [1,1,1,1,1,1,1,0], part.state

    new_part = Dino::Register::ShiftInput.new(options.merge(bytes: 2))
    new_part.update("127,128")
    assert_equal [1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1], new_part.state
  end
  
  def test_callbacks_get_bit_array
    mock = MiniTest::Mock.new.expect :call, nil, [[1,1,1,1,1,1,1,0]]
    part.add_callback do |data|
      mock.call(data)
    end
    part.update("127")
    mock.verify
  end
  
  def test_read_proxy
    # Stop automatic listening first.
    button.stop
    
    # Give #read some value so it stops blocking.
    Thread.new do
      sleep while !part.callbacks[:force_update]
      part.update("255")
    end

    mock = MiniTest::Mock.new
    mock.expect :call, nil
    part.stub(:read, mock) do
      button.read
    end
    mock.verify
  end

  def test_listener_proxy
    mock = MiniTest::Mock.new
    mock.expect :call, nil
    part.stub(:listen, mock) do
      # Tells the register to start listening when it initializees.
      button
      
      # Should not make a second listen call to the board.
      button1 = Dino::DigitalIO::Button.new(board: part, pin: 1)
    end
    mock.verify
    
    # Should be listening to the lowest 2 bits now.
    assert_equal part.instance_variable_get(:@listening_pins), [true, true, false, false, false, false, false, false]
  end
  
  def test_stop_listener_proxy
    button
    
    # Calling stop on a child part, when only it is listening, should call stop on the register too.
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:stop, mock) do
      button.stop
    end
    mock.verify
    
    # Check listener tracking is correct.
    assert_equal part.instance_variable_get(:@listening_pins), Array.new(8) { false }
    refute part.any_listening
  end
end
