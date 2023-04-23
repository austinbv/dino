require_relative '../test_helper'

class OutputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Dino::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus, pin: 9, frequency: 800000, spi_mode: 2, bit_order: :lsbfirst, bytes: 2 }
  end

  def part
    @part ||= Dino::SPI::OutputRegister.new(options)
  end
  
  def led
    @led ||= Dino::LED.new(board: part, pin: 0)
  end

  def test_write
    part
    mock = MiniTest::Mock.new.expect :call, nil, [9], mode: 2, frequency: 800000, write: [255,127], bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      part.write(255,127)
    end
    mock.verify
  end
  
  def test_state_setup
    assert_equal part.instance_variable_get(:@write_delay), 0.001
    assert_equal part.instance_variable_get(:@buffer_writes), true
  end
  
  def test_write_buffering_control
    new_part = Dino::SPI::OutputRegister.new(options.merge(buffer_writes: false, write_delay: 0.5))
    assert_equal new_part.instance_variable_get(:@write_delay), 0.5
    assert_equal new_part.instance_variable_get(:@buffer_writes), false
  end
  
  def test_updates_and_writes_state_for_children
    led
    
    mock = MiniTest::Mock.new.expect :call, nil, [[0, 1]]
    part.stub(:write, mock) do
      led.on
      sleep 0.050
    end
    mock.verify
    
    expected_state = Array.new(options[:bytes] * 8) { |i| 0 }
    expected_state[0] = 1

    assert_equal expected_state, part.state
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