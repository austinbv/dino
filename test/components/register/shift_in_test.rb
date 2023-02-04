require 'dino'
require 'board_mock'
require 'minitest/autorun'

class RegisterShiftInTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { clock: 12, data: 11, latch: 8 } }
  end

  def part
    @part ||= Dino::Components::Register::ShiftIn.new(options)
  end

  def test_proxies
    assert_equal Dino::Components::Basic::DigitalOutput, part.clock.class
    assert_equal Dino::Components::Basic::DigitalInput,  part.data.class
    assert_equal Dino::Components::Register::Select,     part.latch.class
  end

  def test_byte_length
    new_part = Dino::Components::Register::ShiftIn.new(options.merge(bytes: 2))
    assert_equal 2, new_part.bytes
  end

  def test_rising_clock
    assert_equal part.rising_clock, false
    new_part = Dino::Components::Register::ShiftIn.new(options.merge(rising_clock: :yes))
    assert_equal true, new_part.rising_clock
  end

  def test_read
    mock = MiniTest::Mock.new.expect :call, nil, [8, 11, 12, 2], preclock_high: true
    board.stub(:shift_read, mock) do
      new_part = Dino::Components::Register::ShiftIn.new(options.merge(bytes: 2, rising_clock: true))
      new_part.read
    end
    mock.verify
  end
  
  def test_listen
    mock = MiniTest::Mock.new.expect :call, nil, [8, 11, 12, 2], preclock_high: true
    board.stub(:shift_listen, mock) do
      new_part = Dino::Components::Register::ShiftIn.new(options.merge(bytes: 2, rising_clock: true))
      new_part.listen
    end
    mock.verify
  end
  
  def test_stop
    mock = MiniTest::Mock.new.expect :call, nil, [8]
    board.stub(:shift_stop, mock) do
      new_part = Dino::Components::Register::ShiftIn.new(options.merge(bytes: 2, rising_clock: true))
      new_part.stop
    end
    mock.verify
  end
  
  def test_callback_bubble
    mock = MiniTest::Mock.new.expect :call, nil, ["127,255"]
    part.stub(:update, mock) do
      part.latch.update "127,255"
    end
    mock.verify
  end

  def test_bit_array_conversion
    part.update("127")
    assert_equal [0,1,1,1,1,1,1,1], part.state

    new_part = Dino::Components::Register::ShiftIn.new(options.merge(bytes: 2))
    new_part.update("127,255")
    assert_equal [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], new_part.state
  end

  def test_callbacks_get_bit_array
    mock = MiniTest::Mock.new.expect :call, nil, [[0,1,1,1,1,1,1,1]]
    part.add_callback do |data|
      mock.call(data)
    end
    part.update("127")
    mock.verify
  end
end
